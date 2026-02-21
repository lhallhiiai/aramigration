-- =============================================================================
-- ARA Database Schema Migration
-- Script:  001_tables.sql
-- Purpose: Create all tables for the ARA application.
--          Idempotent: wrapped in IF NOT EXISTS checks, safe to re-run.
--
-- Naming conventions (CLAUDE.md):
--   Tables:  PascalCase singular  (User, Ara, Clin)
--   Columns: PascalCase           (UserId, CreatedAt)
--
-- Legacy mapping notes are included as inline comments.
-- =============================================================================

SET NOCOUNT ON;
GO

-- =============================================================================
-- LOOKUP / REFERENCE TABLES  (no FK dependencies)
-- =============================================================================

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Role' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.Role
    (
        RoleId    INT          NOT NULL IDENTITY(1,1) CONSTRAINT PK_Role PRIMARY KEY,
        RoleName  NVARCHAR(50) NOT NULL,  -- e.g. "Creator", "Contract Administrator"
        RoleShort NVARCHAR(50) NULL,
        RoleDesc  NVARCHAR(200) NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Sector' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.Sector
    (
        SectorId   INT          NOT NULL CONSTRAINT PK_Sector PRIMARY KEY,
        SectorName NVARCHAR(50) NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'JobTitle' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.JobTitle
    (
        JobTitleId  INT           NOT NULL CONSTRAINT PK_JobTitle PRIMARY KEY,
        Title       NVARCHAR(100) NULL,
        Description NVARCHAR(MAX) NULL,
        AppOrder    INT           NULL,   -- NULL for non-approver roles (PM, CA, Controller)
        IsInactive  BIT           NOT NULL CONSTRAINT DF_JobTitle_IsInactive DEFAULT 0
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Category' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.Category
    (
        CategoryId   INT          NOT NULL IDENTITY(1,1) CONSTRAINT PK_Category PRIMARY KEY,
        CategoryName NVARCHAR(50) NULL,   -- legacy: catName
        RiskLevel    INT          NULL,   -- joins to Threshold.RiskLevel
        Color        NVARCHAR(50) NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Status' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.Status
    (
        StatusId   INT          NOT NULL IDENTITY(1,1) CONSTRAINT PK_Status PRIMARY KEY,
        StatusName NVARCHAR(75) NULL,
        OneWord    NVARCHAR(50) NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'EarlyStartReason' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.EarlyStartReason
    (
        EarlyStartReasonId INT          NOT NULL IDENTITY(1,1) CONSTRAINT PK_EarlyStartReason PRIMARY KEY,
        Reason             NVARCHAR(50) NULL     -- legacy: esReason.reason
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'RevenueDescription' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.RevenueDescription
    (
        RevenueDescriptionId INT           NOT NULL IDENTITY(1,1) CONSTRAINT PK_RevenueDescription PRIMARY KEY,
        Description          NVARCHAR(250) NULL    -- legacy: revenueDescr.Descr
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'CustomerType' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.CustomerType
    (
        CustomerTypeId INT          NOT NULL IDENTITY(1,1) CONSTRAINT PK_CustomerType PRIMARY KEY,
        Description    NVARCHAR(50) NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'RejectionReason' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.RejectionReason
    (
        RejectionReasonId INT           NOT NULL IDENTITY(1,1) CONSTRAINT PK_RejectionReason PRIMARY KEY,
        Reason            NVARCHAR(100) NULL,
        Description       NVARCHAR(250) NULL   -- legacy: Descr
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'EmailType' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.EmailType
    (
        EmailTypeId     INT           NOT NULL IDENTITY(1,1) CONSTRAINT PK_EmailType PRIMARY KEY,
        EmailType       NVARCHAR(50)  NULL,
        LongDescription NVARCHAR(255) NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Threshold' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    -- Approval and Threshold Matrix.
    -- Ambiguity #1 (CLAUDE.md): actual dollar thresholds and routing rules must be
    -- confirmed with the product owner before this table can be seeded.
    CREATE TABLE dbo.Threshold
    (
        ThresholdId    INT           NOT NULL IDENTITY(1,1) CONSTRAINT PK_Threshold PRIMARY KEY,
        RiskLevel      INT           NULL,   -- joins to Category.RiskLevel
        JobTitleId     INT           NULL,   -- the approver role required at this threshold
        LowThreshold   INT           NULL,   -- legacy: low_thresh
        HighThreshold  INT           NULL,   -- legacy: high_thresh
        ReviewApprove  NVARCHAR(20)  NULL,   -- 'Review' or 'Approve'
        CanDelegate    BIT           NULL,   -- legacy: delegate
        CreatedAt      DATETIME2     NOT NULL CONSTRAINT DF_Threshold_CreatedAt DEFAULT GETUTCDATE(),
        UpdatedAt      DATETIME2     NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'AttachmentRequirement' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    -- Document checklist items selectable during CA and Controller document upload.
    -- legacy: attach_checklist
    CREATE TABLE dbo.AttachmentRequirement
    (
        AttachmentRequirementId INT           NOT NULL IDENTITY(1,1) CONSTRAINT PK_AttachmentRequirement PRIMARY KEY,
        CategoryIdList          NVARCHAR(50)  NULL,   -- comma-separated CategoryIds this applies to
        ShortDescription        NVARCHAR(60)  NULL,
        LongDescription         NVARCHAR(500) NULL,
        DisplayOrder            INT           NULL,
        ApplicableRole          NVARCHAR(50)  NULL,   -- 'CA' or 'Controller'
        StatusComment           NVARCHAR(100) NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'QuestionMap' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    -- Configurable list of PM/CA questions and their $50K applicability.
    -- Resolves ambiguity #2 (CLAUDE.md): questions are DB-driven, not hard-coded.
    -- legacy: Cat_Questions_Map
    CREATE TABLE dbo.QuestionMap
    (
        QuestionMapId  INT           NOT NULL IDENTITY(1,1) CONSTRAINT PK_QuestionMap PRIMARY KEY,
        Tab            NVARCHAR(30)  NULL,    -- 'PM' or 'CA'
        CategoryIdList NVARCHAR(100) NULL,    -- comma-separated CategoryIds this question applies to
        Question       NVARCHAR(255) NULL,
        SourceType     NVARCHAR(20)  NULL,    -- 'ods' or 'user' — legacy: ods_or_user
        ToolTip        NVARCHAR(255) NULL,
        DisplayOrder   INT           NULL,
        Comment        NVARCHAR(255) NULL
    );
END
GO

-- =============================================================================
-- USER TABLE
-- =============================================================================

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'User' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[User]
    (
        UserId            INT            NOT NULL IDENTITY(1,1) CONSTRAINT PK_User PRIMARY KEY,
        EntraObjectId     NVARCHAR(100)  NOT NULL,             -- Entra ID OID — replaces oprid/password
        EmployeeId        NVARCHAR(50)   NULL,                 -- legacy: emplID
        LegacyOprid       NVARCHAR(50)   NULL,                 -- legacy: oprid (migration reference only)
        DisplayName       NVARCHAR(500)  NOT NULL,             -- legacy: empname
        FirstName         NVARCHAR(100)  NULL,                 -- legacy: first_name
        LastName          NVARCHAR(100)  NULL,                 -- legacy: last_name
        Email             NVARCHAR(255)  NULL,
        RoleId            INT            NOT NULL CONSTRAINT FK_User_Role REFERENCES dbo.Role(RoleId),
        JobTitleId        INT            NULL    CONSTRAINT FK_User_JobTitle REFERENCES dbo.JobTitle(JobTitleId),
        SectorId          INT            NULL    CONSTRAINT FK_User_Sector REFERENCES dbo.Sector(SectorId),
        ApprovalGroups    NVARCHAR(500)  NULL,  -- comma-separated division codes — legacy: Approve_grp
        ApprovalOperation NVARCHAR(50)   NULL,  -- legacy: Approve_op
        ApprovalDivision  NVARCHAR(50)   NULL,  -- legacy: Approve_div
        IsInactive        BIT            NOT NULL CONSTRAINT DF_User_IsInactive DEFAULT 0,
        CreatedAt         DATETIME2      NOT NULL CONSTRAINT DF_User_CreatedAt DEFAULT GETUTCDATE(),
        UpdatedAt         DATETIME2      NULL
    );

    CREATE UNIQUE INDEX UX_User_EntraObjectId ON dbo.[User] (EntraObjectId);
END
GO

-- =============================================================================
-- ARA (MAIN TABLE)
-- =============================================================================

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Ara' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.Ara
    (
        AraId                   INT            NOT NULL IDENTITY(1,1) CONSTRAINT PK_Ara PRIMARY KEY,

        -- Category / status FKs
        CategoryId              INT            NOT NULL CONSTRAINT FK_Ara_Category   REFERENCES dbo.Category(CategoryId),
        StatusId                INT            NOT NULL CONSTRAINT FK_Ara_Status     REFERENCES dbo.Status(StatusId),

        -- User assignments
        CreatedByUserId         INT            NULL    CONSTRAINT FK_Ara_CreatedBy   REFERENCES dbo.[User](UserId),
        ProgramManagerId        INT            NULL    CONSTRAINT FK_Ara_PM          REFERENCES dbo.[User](UserId),
        ContractAdministratorId INT            NULL    CONSTRAINT FK_Ara_CA          REFERENCES dbo.[User](UserId),
        ControllerId            INT            NULL    CONSTRAINT FK_Ara_Controller  REFERENCES dbo.[User](UserId),
        OpsVpUserId             INT            NULL    CONSTRAINT FK_Ara_OpsVP       REFERENCES dbo.[User](UserId),

        -- Identification
        Reference               NVARCHAR(50)   NULL,  -- display number, e.g. "00001234" — legacy: reference
        Revision                INT            NOT NULL CONSTRAINT DF_Ara_Revision DEFAULT 0,
        JamisId                 NVARCHAR(50)   NULL,  -- populated after JAMIS export — legacy: jamisNo

        -- Org and contract
        Division                NVARCHAR(50)   NULL,  -- org division code used for approval routing
        ContractNumber          NVARCHAR(50)   NULL,  -- JAMIS contract number (Non-Early Start) — legacy: contractNo
        DeliveryOrderNumber     NVARCHAR(50)   NULL,  -- legacy: doNo
        ContractType            NVARCHAR(50)   NULL,
        OmsNumber               NVARCHAR(50)   NULL,  -- OMS opportunity number (Early Start only) — legacy: OMSNum

        -- ARA content
        Title                   NVARCHAR(500)  NULL,
        CustomerName            NVARCHAR(500)  NULL,  -- legacy: customerName
        AmountTotal             MONEY          NOT NULL CONSTRAINT DF_Ara_AmountTotal DEFAULT 0,
        AmountRequested         MONEY          NULL,
        TotalAnticipated        MONEY          NULL,
        PercentAnticipated      FLOAT          NULL,
        RevenueDescriptionId    INT            NULL,  -- legacy: ID_Revenue → revenueDescr

        -- Early Start
        IsEarlyStart            BIT            NOT NULL CONSTRAINT DF_Ara_IsEarlyStart DEFAULT 0,
        EarlyStartReasonId      INT            NULL   CONSTRAINT FK_Ara_EarlyStartReason REFERENCES dbo.EarlyStartReason(EarlyStartReasonId),
        EarlyStartReasonOther   NVARCHAR(MAX)  NULL,  -- legacy: esOther

        -- Misc
        Company                 NVARCHAR(10)   NULL,  -- company code for JAMIS export segmentation
        IsEac                   NVARCHAR(5)    NULL,

        -- Lifecycle dates
        StartDate               DATETIME2      NULL,
        ExpirationDate          DATETIME2      NULL,  -- legacy: expirationDate
        CreatedAt               DATETIME2      NOT NULL CONSTRAINT DF_Ara_CreatedAt DEFAULT GETUTCDATE(),
        UpdatedAt               DATETIME2      NULL,
        ExportedAt              DATETIME2      NULL,
        NegatedAt               DATETIME2      NULL,
        CancelledAt             DATETIME2      NULL
    );
END
GO

-- =============================================================================
-- ARA SECTION TABLES
-- =============================================================================

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'AraPmSection' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    -- PM narrative answers. Questions suppressed for amounts ≤ $50K. legacy: ara_PM
    CREATE TABLE dbo.AraPmSection
    (
        AraPmSectionId      INT           NOT NULL IDENTITY(1,1) CONSTRAINT PK_AraPmSection PRIMARY KEY,
        AraId               INT           NOT NULL CONSTRAINT FK_AraPmSection_Ara REFERENCES dbo.Ara(AraId),
        FundsInAdvance      NVARCHAR(MAX) NULL,
        ContractDefinization NVARCHAR(MAX) NULL,
        PertinentInformation NVARCHAR(MAX) NULL,
        WorkStarted         NVARCHAR(MAX) NULL,
        Consequence         NVARCHAR(MAX) NULL,
        CurrentStatus       NVARCHAR(MAX) NULL,
        ChangeInScope       NVARCHAR(MAX) NULL,
        ActionToClear       NVARCHAR(MAX) NULL,
        EarlyStartNecessary NVARCHAR(MAX) NULL,  -- legacy: ES_Necessary
        OtherNecessary      NVARCHAR(MAX) NULL   -- legacy: Other_necessary
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'AraCaSection' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    -- CA section answers. legacy: ara_cm
    CREATE TABLE dbo.AraCaSection
    (
        AraCaSectionId                 INT            NOT NULL IDENTITY(1,1) CONSTRAINT PK_AraCaSection PRIMARY KEY,
        AraId                          INT            NOT NULL CONSTRAINT FK_AraCaSection_Ara REFERENCES dbo.Ara(AraId),
        CaUserId                       INT            NULL    CONSTRAINT FK_AraCaSection_User REFERENCES dbo.[User](UserId),
        CustomerTypeId                 INT            NULL    CONSTRAINT FK_AraCaSection_CustomerType REFERENCES dbo.CustomerType(CustomerTypeId),
        ContractType                   NVARCHAR(50)   NULL,
        AuthorizationStartDate         DATETIME2      NULL,   -- legacy: authStart
        ExecutionDate                  DATETIME2      NULL,
        CustomerPo                     NVARCHAR(50)   NULL,   -- legacy: customerPO
        PoContactDate                  DATETIME2      NULL,   -- legacy: POContactDate
        PcCostAuthorization            MONEY          NULL,   -- legacy: PCCostAuth
        FundsToSupport                 INT            NULL,
        FundsExplanation               NVARCHAR(MAX)  NULL,
        CreditCheck                    INT            NULL,
        CreditExplanation              NVARCHAR(MAX)  NULL,
        AllApprovals                   INT            NULL,
        AllApprovalsExplanation        NVARCHAR(MAX)  NULL,
        Forwarded                      INT            NULL,
        ForwardedExplanation           NVARCHAR(MAX)  NULL,
        WorkAuthorization              INT            NULL,
        WorkAuthorizationExplanation   NVARCHAR(MAX)  NULL,
        AuthorizationType              NVARCHAR(70)   NULL,   -- legacy: authType
        WrittenConfirmation            INT            NULL,
        WrittenConfirmationExplanation NVARCHAR(70)   NULL,
        AlionConfirmation              INT            NULL,   -- legacy: alion_conf
        AlionConfirmationExplanation   NVARCHAR(70)   NULL,
        AnticipatoryRisk               INT            NULL,   -- legacy: anticipatoryCost
        AnticipatoryRiskExplanation    NVARCHAR(70)   NULL,
        AnticipatedNegotiationDate     DATETIME2      NULL,
        CaCertificationDate            DATETIME2      NULL,   -- legacy: CACertification
        EstimatedModificationExecDate  DATETIME2      NULL,   -- legacy: estModExeDate
        InternalClearCompletionDate    DATETIME2      NULL,   -- legacy: intClearCompDate
        PeriodOfPerformance            NVARCHAR(MAX)  NULL,   -- legacy: pop
        PoolAmount                     FLOAT          NULL,
        EstimatedFundingDate           DATETIME2      NULL,   -- legacy: estFunDate
        PeriodOfPerformanceEnd         DATETIME2      NULL    -- legacy: pop2
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'AraControllerSection' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    -- Controller section. Ambiguity #4 resolved: InterestImpact and BurnRate are float fields. legacy: ara_con
    CREATE TABLE dbo.AraControllerSection
    (
        AraControllerSectionId INT          NOT NULL IDENTITY(1,1) CONSTRAINT PK_AraControllerSection PRIMARY KEY,
        AraId                  INT          NOT NULL CONSTRAINT FK_AraControllerSection_Ara      REFERENCES dbo.Ara(AraId),
        ControllerId           INT          NULL    CONSTRAINT FK_AraControllerSection_Controller REFERENCES dbo.[User](UserId),
        InterestImpact         FLOAT        NULL,   -- legacy: interestImpact
        BurnRate               FLOAT        NULL,   -- legacy: burnRate (Expected Burn Rate)
        TotalCost              FLOAT        NULL,   -- auto-calculated — legacy: total_cost
        TotalFee               FLOAT        NULL,   -- auto-calculated — legacy: total_fee
        IncurredCost           FLOAT        NULL,   -- legacy: icCost
        IncurredFee            FLOAT        NULL,   -- legacy: icFee
        Company                NVARCHAR(10) NULL
    );
END
GO

-- =============================================================================
-- CLIN WORKSHEET
-- =============================================================================

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Clin' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.Clin
    (
        ClinId          INT           NOT NULL IDENTITY(1,1) CONSTRAINT PK_Clin PRIMARY KEY,
        AraId           INT           NOT NULL CONSTRAINT FK_Clin_Ara REFERENCES dbo.Ara(AraId),
        ClinNumber      NVARCHAR(50)  NOT NULL,   -- legacy: clinNo
        Description     NVARCHAR(MAX) NULL,
        ExpirationDate  DATETIME2     NULL,
        RevisionAmount  MONEY         NULL,        -- legacy: revisionAmt
        CostFunding     MONEY         NULL,        -- legacy: costFunding
        FeeFunding      MONEY         NULL,        -- legacy: feeFunding
        Total           MONEY         NULL,        -- auto-calculated (CostFunding + FeeFunding)
        CameFromJamis   BIT           NOT NULL CONSTRAINT DF_Clin_CameFromJamis DEFAULT 0,
        IsNegated       BIT           NOT NULL CONSTRAINT DF_Clin_IsNegated DEFAULT 0,  -- legacy: negate
        CreatedAt       DATETIME2     NOT NULL CONSTRAINT DF_Clin_CreatedAt DEFAULT GETUTCDATE(),
        UpdatedAt       DATETIME2     NULL
    );
END
GO

-- =============================================================================
-- APPROVAL TABLES
-- =============================================================================

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'AraApprovalAssignment' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    -- Pre-assigned approval chain for each ARA, set at creation. legacy: araAppList
    CREATE TABLE dbo.AraApprovalAssignment
    (
        AraApprovalAssignmentId INT NOT NULL IDENTITY(1,1) CONSTRAINT PK_AraApprovalAssignment PRIMARY KEY,
        AraId                   INT NOT NULL CONSTRAINT FK_AraApprovalAssignment_Ara REFERENCES dbo.Ara(AraId),
        ProgramManagerId        INT NULL CONSTRAINT FK_AAA_PM     REFERENCES dbo.[User](UserId),
        ContractAdminId         INT NULL CONSTRAINT FK_AAA_CA     REFERENCES dbo.[User](UserId),
        ControllerId            INT NULL CONSTRAINT FK_AAA_Con    REFERENCES dbo.[User](UserId),
        GroupContractsManagerId INT NULL CONSTRAINT FK_AAA_GCM    REFERENCES dbo.[User](UserId),
        GroupControllerId       INT NULL CONSTRAINT FK_AAA_GCon   REFERENCES dbo.[User](UserId),
        DivisionManagerId       INT NULL CONSTRAINT FK_AAA_DM     REFERENCES dbo.[User](UserId),
        OperationManagerId      INT NULL CONSTRAINT FK_AAA_OM     REFERENCES dbo.[User](UserId),
        GroupManagerId          INT NULL CONSTRAINT FK_AAA_GM     REFERENCES dbo.[User](UserId),
        SectorContractsMgrId    INT NULL CONSTRAINT FK_AAA_SCM    REFERENCES dbo.[User](UserId),
        SectorControllerId      INT NULL CONSTRAINT FK_AAA_SCon   REFERENCES dbo.[User](UserId),
        SectorManagerId         INT NULL CONSTRAINT FK_AAA_SM     REFERENCES dbo.[User](UserId),
        CaoId                   INT NULL CONSTRAINT FK_AAA_CAO    REFERENCES dbo.[User](UserId),
        CfoId                   INT NULL CONSTRAINT FK_AAA_CFO    REFERENCES dbo.[User](UserId),
        CooId                   INT NULL CONSTRAINT FK_AAA_COO    REFERENCES dbo.[User](UserId),
        CeoId                   INT NULL CONSTRAINT FK_AAA_CEO    REFERENCES dbo.[User](UserId),
        Cycle                   INT NULL   -- approval cycle / revision number
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'AraApprovalLog' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    -- Append-only record of every action taken by an approver. legacy: araAppLog
    CREATE TABLE dbo.AraApprovalLog
    (
        AraApprovalLogId    INT           NOT NULL IDENTITY(1,1) CONSTRAINT PK_AraApprovalLog PRIMARY KEY,
        AraId               INT           NOT NULL CONSTRAINT FK_AraApprovalLog_Ara      REFERENCES dbo.Ara(AraId),
        UserId              INT           NULL    CONSTRAINT FK_AraApprovalLog_User     REFERENCES dbo.[User](UserId),
        JobTitleId          INT           NULL    CONSTRAINT FK_AraApprovalLog_JobTitle REFERENCES dbo.JobTitle(JobTitleId),
        StatusId            INT           NULL,   -- ARA status at time of action
        IsRejection         BIT           NULL,
        Comment             NVARCHAR(MAX) NULL,
        ActionDate          DATETIME2     NULL,   -- legacy: approvalDate
        Cycle               INT           NULL,   -- ARA revision number at time of action
        RejectionReasonId   INT           NULL    CONSTRAINT FK_AraApprovalLog_RejReason REFERENCES dbo.RejectionReason(RejectionReasonId),
        RejectionAreas      NVARCHAR(100) NULL,   -- legacy: Rej_areas
        SequenceOrder       INT           NULL    -- position in approval chain
    );
END
GO

-- =============================================================================
-- DOCUMENT ATTACHMENTS
-- =============================================================================

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'AraAttachment' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    -- Documents stored in Azure Blob Storage; only the path is kept here.
    -- Legacy stored binary in the DB (binary_file varbinary(max)); that pattern is not used.
    CREATE TABLE dbo.AraAttachment
    (
        AraAttachmentId INT            NOT NULL IDENTITY(1,1) CONSTRAINT PK_AraAttachment PRIMARY KEY,
        AraId           INT            NOT NULL CONSTRAINT FK_AraAttachment_Ara  REFERENCES dbo.Ara(AraId),
        UploadedByUserId INT           NULL    CONSTRAINT FK_AraAttachment_User REFERENCES dbo.[User](UserId),
        FileName        NVARCHAR(260)  NOT NULL,
        StoragePath     NVARCHAR(500)  NOT NULL,  -- Azure Blob Storage path / URL
        FileSize        INT            NULL,
        MimeType        NVARCHAR(100)  NULL,
        UploadedAt      DATETIME2      NOT NULL CONSTRAINT DF_AraAttachment_UploadedAt DEFAULT GETUTCDATE()
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'AraAttachmentRequirementLink' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    -- Many-to-many: one attachment can satisfy multiple requirements; one requirement
    -- can be satisfied by multiple attachments.
    CREATE TABLE dbo.AraAttachmentRequirementLink
    (
        AraAttachmentId         INT NOT NULL CONSTRAINT FK_AttReqLink_Att REFERENCES dbo.AraAttachment(AraAttachmentId),
        AttachmentRequirementId INT NOT NULL CONSTRAINT FK_AttReqLink_Req REFERENCES dbo.AttachmentRequirement(AttachmentRequirementId),
        CONSTRAINT PK_AraAttachmentRequirementLink PRIMARY KEY (AraAttachmentId, AttachmentRequirementId)
    );
END
GO

-- =============================================================================
-- DELEGATION
-- =============================================================================

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Delegation' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.Delegation
    (
        DelegationId      INT       NOT NULL IDENTITY(1,1) CONSTRAINT PK_Delegation PRIMARY KEY,
        DelegateFromId    INT       NULL    CONSTRAINT FK_Delegation_From REFERENCES dbo.[User](UserId),
        DelegateToId      INT       NULL,   -- not enforced as FK — delegatee may be external
        DelegateFromOprid NVARCHAR(50) NULL,
        DelegateToOprid   NVARCHAR(50) NULL,
        StartDate         DATETIME2 NULL,
        EndDate           DATETIME2 NULL,
        CreatedAt         DATETIME2 NULL,
        CreatedByUserId   INT       NULL,
        UpdatedAt         DATETIME2 NULL,
        UpdatedByUserId   INT       NULL
    );
END
GO

-- =============================================================================
-- LOGGING TABLES
-- =============================================================================

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'EmailLog' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.EmailLog
    (
        EmailLogId      INT            NOT NULL IDENTITY(1,1) CONSTRAINT PK_EmailLog PRIMARY KEY,
        AraId           INT            NULL    CONSTRAINT FK_EmailLog_Ara REFERENCES dbo.Ara(AraId),
        EmailTypeId     INT            NULL,
        Subject         NVARCHAR(MAX)  NULL,
        Recipients      NVARCHAR(500)  NULL,   -- legacy: MsgTo
        CcRecipients    NVARCHAR(500)  NULL,   -- legacy: MsgCC
        SentAt          DATETIME2      NOT NULL CONSTRAINT DF_EmailLog_SentAt DEFAULT GETUTCDATE(),
        StatusId        INT            NULL,
        AraApprovalLogId INT           NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'AuditLog' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.AuditLog
    (
        AuditLogId  INT            NOT NULL IDENTITY(1,1) CONSTRAINT PK_AuditLog PRIMARY KEY,
        UserId      INT            NULL    CONSTRAINT FK_AuditLog_User REFERENCES dbo.[User](UserId),
        AraId       INT            NULL    CONSTRAINT FK_AuditLog_Ara  REFERENCES dbo.Ara(AraId),
        Event       NVARCHAR(500)  NULL,
        Url         NVARCHAR(150)  NULL,
        LoggedAt    DATETIME2      NOT NULL CONSTRAINT DF_AuditLog_LoggedAt DEFAULT GETUTCDATE()
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'AraExportArchive' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    -- Tracks which ARAs have been exported to JAMIS and when. legacy: ara_export_archive
    CREATE TABLE dbo.AraExportArchive
    (
        AraExportArchiveId INT       NOT NULL IDENTITY(1,1) CONSTRAINT PK_AraExportArchive PRIMARY KEY,
        AraId              INT       NULL    CONSTRAINT FK_AraExportArchive_Ara REFERENCES dbo.Ara(AraId),
        ExportedAt         DATETIME2 NOT NULL CONSTRAINT DF_AraExportArchive_ExportedAt DEFAULT GETUTCDATE()
    );
END
GO

PRINT 'Schema migration 001_tables.sql complete.';
GO
