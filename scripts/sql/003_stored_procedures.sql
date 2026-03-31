-- =============================================================================
-- ARA Stored Procedures
-- Script:  003_stored_procedures.sql
-- Purpose: Create all stored procedures used by the Infrastructure repositories.
--          Idempotent: uses CREATE OR ALTER PROCEDURE.
--
-- Naming convention: usp_[Entity][Action]
--   e.g. usp_AraGetById, usp_UserGetByExternalUserId
-- =============================================================================

SET NOCOUNT ON;
GO

-- =============================================================================
-- PRE-REQUISITE: Rename EntraObjectId -> ExternalUserId if not already done
-- Runs before stored procedures are created so column references are valid.
-- =============================================================================

IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.[User]')
      AND name = 'EntraObjectId'
)
BEGIN
    EXEC sp_rename 'dbo.[User].EntraObjectId', 'ExternalUserId', 'COLUMN';
END
GO

IF OBJECT_ID('dbo.usp_UserGetByEntraObjectId', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_UserGetByEntraObjectId;
GO

-- =============================================================================
-- USER PROCEDURES
-- =============================================================================

CREATE OR ALTER PROCEDURE dbo.usp_UserGetById
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        UserId, ExternalUserId, EmployeeId, LegacyOprid,
        DisplayName, FirstName, LastName, Email,
        RoleId, JobTitleId, SectorId,
        ApprovalGroups, ApprovalOperation, ApprovalDivision,
        IsInactive, CreatedAt, UpdatedAt
    FROM dbo.[User]
    WHERE UserId = @UserId;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_UserGetByExternalUserId
    @ExternalUserId NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        UserId, ExternalUserId, EmployeeId, LegacyOprid,
        DisplayName, FirstName, LastName, Email,
        RoleId, JobTitleId, SectorId,
        ApprovalGroups, ApprovalOperation, ApprovalDivision,
        IsInactive, CreatedAt, UpdatedAt
    FROM dbo.[User]
    WHERE ExternalUserId = @ExternalUserId;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_UserGetByRole
    @RoleId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        UserId, ExternalUserId, EmployeeId, LegacyOprid,
        DisplayName, FirstName, LastName, Email,
        RoleId, JobTitleId, SectorId,
        ApprovalGroups, ApprovalOperation, ApprovalDivision,
        IsInactive, CreatedAt, UpdatedAt
    FROM dbo.[User]
    WHERE RoleId = @RoleId
      AND IsInactive = 0;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_UserGetAllActive
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        UserId, ExternalUserId, EmployeeId, LegacyOprid,
        DisplayName, FirstName, LastName, Email,
        RoleId, JobTitleId, SectorId,
        ApprovalGroups, ApprovalOperation, ApprovalDivision,
        IsInactive, CreatedAt, UpdatedAt
    FROM dbo.[User]
    WHERE IsInactive = 0
    ORDER BY LastName, FirstName;
END
GO

-- =============================================================================
-- CATEGORY PROCEDURES
-- =============================================================================

CREATE OR ALTER PROCEDURE dbo.usp_CategoryGetAll
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CategoryId, CategoryName, RiskLevel, Color
    FROM dbo.Category
    ORDER BY CategoryId;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_CategoryGetById
    @CategoryId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CategoryId, CategoryName, RiskLevel, Color
    FROM dbo.Category
    WHERE CategoryId = @CategoryId;
END
GO

-- =============================================================================
-- JOB TITLE PROCEDURES
-- =============================================================================

CREATE OR ALTER PROCEDURE dbo.usp_JobTitleGetAllActive
AS
BEGIN
    SET NOCOUNT ON;

    SELECT JobTitleId, Title, Description, AppOrder, IsInactive
    FROM dbo.JobTitle
    WHERE IsInactive = 0
    ORDER BY ISNULL(AppOrder, 9999), JobTitleId;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_JobTitleGetById
    @JobTitleId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT JobTitleId, Title, Description, AppOrder, IsInactive
    FROM dbo.JobTitle
    WHERE JobTitleId = @JobTitleId;
END
GO

-- =============================================================================
-- ARA PROCEDURES
-- =============================================================================

CREATE OR ALTER PROCEDURE dbo.usp_AraGetById
    @AraId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        AraId, CategoryId, StatusId,
        CreatedByUserId, ProgramManagerId, ContractAdministratorId,
        ControllerId, OpsVpUserId,
        Reference, Revision, JamisId,
        Division, ContractNumber, DeliveryOrderNumber, ContractType, OmsNumber,
        Title, CustomerName,
        AmountTotal, AmountRequested, TotalAnticipated, PercentAnticipated,
        RevenueDescriptionId, IsEarlyStart, EarlyStartReasonId, EarlyStartReasonOther,
        Company, IsEac,
        StartDate, ExpirationDate,
        CreatedAt, UpdatedAt, ExportedAt, NegatedAt, CancelledAt
    FROM dbo.Ara
    WHERE AraId = @AraId;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_AraGetPendingForUser
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Retrieve the user's job title to determine their workflow role.
    DECLARE @JobTitleId INT;
    DECLARE @RoleId     INT;

    SELECT @JobTitleId = JobTitleId, @RoleId = RoleId
    FROM dbo.[User]
    WHERE UserId = @UserId;

    -- PM (RoleId = 1): ARAs in any non-terminal status where they are ProgramManager
    IF @RoleId = 1
    BEGIN
        SELECT a.AraId, a.CategoryId, a.StatusId,
               a.CreatedByUserId, a.ProgramManagerId, a.ContractAdministratorId,
               a.ControllerId, a.OpsVpUserId,
               a.Reference, a.Revision, a.JamisId,
               a.Division, a.ContractNumber, a.DeliveryOrderNumber, a.ContractType, a.OmsNumber,
               a.Title, a.CustomerName,
               a.AmountTotal, a.AmountRequested, a.TotalAnticipated, a.PercentAnticipated,
               a.RevenueDescriptionId, a.IsEarlyStart, a.EarlyStartReasonId, a.EarlyStartReasonOther,
               a.Company, a.IsEac,
               a.StartDate, a.ExpirationDate,
               a.CreatedAt, a.UpdatedAt, a.ExportedAt, a.NegatedAt, a.CancelledAt
        FROM dbo.Ara a
        WHERE a.ProgramManagerId = @UserId
          AND a.StatusId IN (1, 2, 3, 4) -- Draft through PendingApproval
          AND a.CancelledAt IS NULL
          AND a.NegatedAt IS NULL;
        RETURN;
    END

    -- CA (RoleId = 2): ARAs in PendingContractAdministrator (StatusId = 2)
    IF @RoleId = 2
    BEGIN
        SELECT a.AraId, a.CategoryId, a.StatusId,
               a.CreatedByUserId, a.ProgramManagerId, a.ContractAdministratorId,
               a.ControllerId, a.OpsVpUserId,
               a.Reference, a.Revision, a.JamisId,
               a.Division, a.ContractNumber, a.DeliveryOrderNumber, a.ContractType, a.OmsNumber,
               a.Title, a.CustomerName,
               a.AmountTotal, a.AmountRequested, a.TotalAnticipated, a.PercentAnticipated,
               a.RevenueDescriptionId, a.IsEarlyStart, a.EarlyStartReasonId, a.EarlyStartReasonOther,
               a.Company, a.IsEac,
               a.StartDate, a.ExpirationDate,
               a.CreatedAt, a.UpdatedAt, a.ExportedAt, a.NegatedAt, a.CancelledAt
        FROM dbo.Ara a
        WHERE a.ContractAdministratorId = @UserId
          AND a.StatusId = 2; -- PendingContractAdministrator
        RETURN;
    END

    -- Controller (RoleId = 3): ARAs in PendingController (StatusId = 3)
    IF @RoleId = 3
    BEGIN
        SELECT a.AraId, a.CategoryId, a.StatusId,
               a.CreatedByUserId, a.ProgramManagerId, a.ContractAdministratorId,
               a.ControllerId, a.OpsVpUserId,
               a.Reference, a.Revision, a.JamisId,
               a.Division, a.ContractNumber, a.DeliveryOrderNumber, a.ContractType, a.OmsNumber,
               a.Title, a.CustomerName,
               a.AmountTotal, a.AmountRequested, a.TotalAnticipated, a.PercentAnticipated,
               a.RevenueDescriptionId, a.IsEarlyStart, a.EarlyStartReasonId, a.EarlyStartReasonOther,
               a.Company, a.IsEac,
               a.StartDate, a.ExpirationDate,
               a.CreatedAt, a.UpdatedAt, a.ExportedAt, a.NegatedAt, a.CancelledAt
        FROM dbo.Ara a
        WHERE a.ControllerId = @UserId
          AND a.StatusId = 3; -- PendingController
        RETURN;
    END

    -- Approver (RoleId = 4): ARAs in PendingApproval within the user's approval divisions.
    -- Full threshold-matrix routing is implemented in Phase 2; this returns the
    -- broad candidate set filtered by division scope.
    IF @RoleId = 4
    BEGIN
        DECLARE @DivisionList TABLE (Division NVARCHAR(10));

        INSERT INTO @DivisionList (Division)
        SELECT LTRIM(RTRIM(value))
        FROM STRING_SPLIT(
            ISNULL((SELECT ApprovalGroups FROM dbo.[User] WHERE UserId = @UserId), ''), ','
        )
        WHERE LTRIM(RTRIM(value)) <> '';

        SELECT a.AraId, a.CategoryId, a.StatusId,
               a.CreatedByUserId, a.ProgramManagerId, a.ContractAdministratorId,
               a.ControllerId, a.OpsVpUserId,
               a.Reference, a.Revision, a.JamisId,
               a.Division, a.ContractNumber, a.DeliveryOrderNumber, a.ContractType, a.OmsNumber,
               a.Title, a.CustomerName,
               a.AmountTotal, a.AmountRequested, a.TotalAnticipated, a.PercentAnticipated,
               a.RevenueDescriptionId, a.IsEarlyStart, a.EarlyStartReasonId, a.EarlyStartReasonOther,
               a.Company, a.IsEac,
               a.StartDate, a.ExpirationDate,
               a.CreatedAt, a.UpdatedAt, a.ExportedAt, a.NegatedAt, a.CancelledAt
        FROM dbo.Ara a
        WHERE a.StatusId = 4 -- PendingApproval
          AND a.Division IN (SELECT Division FROM @DivisionList);
        RETURN;
    END
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_AraGetAllActive
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        AraId, CategoryId, StatusId,
        CreatedByUserId, ProgramManagerId, ContractAdministratorId,
        ControllerId, OpsVpUserId,
        Reference, Revision, JamisId,
        Division, ContractNumber, DeliveryOrderNumber, ContractType, OmsNumber,
        Title, CustomerName,
        AmountTotal, AmountRequested, TotalAnticipated, PercentAnticipated,
        RevenueDescriptionId, IsEarlyStart, EarlyStartReasonId, EarlyStartReasonOther,
        Company, IsEac,
        StartDate, ExpirationDate,
        CreatedAt, UpdatedAt, ExportedAt, NegatedAt, CancelledAt
    FROM dbo.Ara
    WHERE StatusId NOT IN (6, 7, 8, 9) -- exclude Exported, Expired, Negated, Cancelled
      AND CancelledAt IS NULL
    ORDER BY CreatedAt DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_AraGetByStatus
    @StatusId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        AraId, CategoryId, StatusId,
        CreatedByUserId, ProgramManagerId, ContractAdministratorId,
        ControllerId, OpsVpUserId,
        Reference, Revision, JamisId,
        Division, ContractNumber, DeliveryOrderNumber, ContractType, OmsNumber,
        Title, CustomerName,
        AmountTotal, AmountRequested, TotalAnticipated, PercentAnticipated,
        RevenueDescriptionId, IsEarlyStart, EarlyStartReasonId, EarlyStartReasonOther,
        Company, IsEac,
        StartDate, ExpirationDate,
        CreatedAt, UpdatedAt, ExportedAt, NegatedAt, CancelledAt
    FROM dbo.Ara
    WHERE StatusId = @StatusId
    ORDER BY CreatedAt DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_AraGetArchived
AS
BEGIN
    SET NOCOUNT ON;

    -- Exported and Negated ARAs accessible from the Archived menu.
    SELECT
        AraId, CategoryId, StatusId,
        CreatedByUserId, ProgramManagerId, ContractAdministratorId,
        ControllerId, OpsVpUserId,
        Reference, Revision, JamisId,
        Division, ContractNumber, DeliveryOrderNumber, ContractType, OmsNumber,
        Title, CustomerName,
        AmountTotal, AmountRequested, TotalAnticipated, PercentAnticipated,
        RevenueDescriptionId, IsEarlyStart, EarlyStartReasonId, EarlyStartReasonOther,
        Company, IsEac,
        StartDate, ExpirationDate,
        CreatedAt, UpdatedAt, ExportedAt, NegatedAt, CancelledAt
    FROM dbo.Ara
    WHERE StatusId IN (6, 8) -- Exported = 6, Negated = 8
    ORDER BY ISNULL(ExportedAt, NegatedAt) DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_AraSearchById
    @SearchTerm NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    -- Quick search by partial or full ARA ID or JAMIS ID.
    SELECT
        AraId, CategoryId, StatusId,
        CreatedByUserId, ProgramManagerId, ContractAdministratorId,
        ControllerId, OpsVpUserId,
        Reference, Revision, JamisId,
        Division, ContractNumber, DeliveryOrderNumber, ContractType, OmsNumber,
        Title, CustomerName,
        AmountTotal, AmountRequested, TotalAnticipated, PercentAnticipated,
        RevenueDescriptionId, IsEarlyStart, EarlyStartReasonId, EarlyStartReasonOther,
        Company, IsEac,
        StartDate, ExpirationDate,
        CreatedAt, UpdatedAt, ExportedAt, NegatedAt, CancelledAt
    FROM dbo.Ara
    WHERE CAST(AraId AS NVARCHAR(20)) LIKE '%' + @SearchTerm + '%'
       OR JamisId               LIKE '%' + @SearchTerm + '%'
       OR Reference             LIKE '%' + @SearchTerm + '%'
    ORDER BY AraId DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_AraGetUpcomingExpirations
AS
BEGIN
    SET NOCOUNT ON;

    -- Dashboard: active ARAs sorted by expected expiration date ascending.
    SELECT
        AraId, CategoryId, StatusId,
        CreatedByUserId, ProgramManagerId, ContractAdministratorId,
        ControllerId, OpsVpUserId,
        Reference, Revision, JamisId,
        Division, ContractNumber, DeliveryOrderNumber, ContractType, OmsNumber,
        Title, CustomerName,
        AmountTotal, AmountRequested, TotalAnticipated, PercentAnticipated,
        RevenueDescriptionId, IsEarlyStart, EarlyStartReasonId, EarlyStartReasonOther,
        Company, IsEac,
        StartDate, ExpirationDate,
        CreatedAt, UpdatedAt, ExportedAt, NegatedAt, CancelledAt
    FROM dbo.Ara
    WHERE StatusId NOT IN (6, 7, 8, 9) -- active only
      AND ExpirationDate IS NOT NULL
    ORDER BY ExpirationDate ASC;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_AraCreate
    @CategoryId              INT,
    @StatusId                INT,
    @CreatedByUserId         INT,
    @ProgramManagerId        INT,
    @ContractAdministratorId INT,
    @ControllerId            INT,
    @OpsVpUserId             INT            = NULL,
    @Division                NVARCHAR(50)   = NULL,
    @ContractNumber          NVARCHAR(50)   = NULL,
    @DeliveryOrderNumber     NVARCHAR(50)   = NULL,
    @ContractType            NVARCHAR(50)   = NULL,
    @OmsNumber               NVARCHAR(50)   = NULL,
    @Title                   NVARCHAR(500)  = NULL,
    @CustomerName            NVARCHAR(500)  = NULL,
    @AmountTotal             MONEY          = 0,
    @AmountRequested         MONEY          = NULL,
    @TotalAnticipated        MONEY          = NULL,
    @PercentAnticipated      FLOAT          = NULL,
    @RevenueDescriptionId    INT            = NULL,
    @IsEarlyStart            BIT            = 0,
    @EarlyStartReasonId      INT            = NULL,
    @EarlyStartReasonOther   NVARCHAR(MAX)  = NULL,
    @Company                 NVARCHAR(10)   = NULL,
    @IsEac                   NVARCHAR(5)    = NULL,
    @StartDate               DATETIME2      = NULL,
    @ExpirationDate          DATETIME2      = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Ara
    (
        CategoryId, StatusId,
        CreatedByUserId, ProgramManagerId, ContractAdministratorId,
        ControllerId, OpsVpUserId,
        Division, ContractNumber, DeliveryOrderNumber, ContractType, OmsNumber,
        Title, CustomerName,
        AmountTotal, AmountRequested, TotalAnticipated, PercentAnticipated,
        RevenueDescriptionId, IsEarlyStart, EarlyStartReasonId, EarlyStartReasonOther,
        Company, IsEac,
        StartDate, ExpirationDate,
        CreatedAt, UpdatedAt
    )
    VALUES
    (
        @CategoryId, @StatusId,
        @CreatedByUserId, @ProgramManagerId, @ContractAdministratorId,
        @ControllerId, @OpsVpUserId,
        @Division, @ContractNumber, @DeliveryOrderNumber, @ContractType, @OmsNumber,
        @Title, @CustomerName,
        @AmountTotal, @AmountRequested, @TotalAnticipated, @PercentAnticipated,
        @RevenueDescriptionId, @IsEarlyStart, @EarlyStartReasonId, @EarlyStartReasonOther,
        @Company, @IsEac,
        @StartDate, @ExpirationDate,
        GETUTCDATE(), GETUTCDATE()
    );

    SELECT SCOPE_IDENTITY() AS AraId;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_AraUpdate
    @AraId                   INT,
    @CategoryId              INT,
    @StatusId                INT,
    @ProgramManagerId        INT,
    @ContractAdministratorId INT,
    @ControllerId            INT,
    @OpsVpUserId             INT            = NULL,
    @Reference               NVARCHAR(50)   = NULL,
    @JamisId                 NVARCHAR(50)   = NULL,
    @Division                NVARCHAR(50)   = NULL,
    @ContractNumber          NVARCHAR(50)   = NULL,
    @DeliveryOrderNumber     NVARCHAR(50)   = NULL,
    @ContractType            NVARCHAR(50)   = NULL,
    @OmsNumber               NVARCHAR(50)   = NULL,
    @Title                   NVARCHAR(500)  = NULL,
    @CustomerName            NVARCHAR(500)  = NULL,
    @AmountTotal             MONEY          = 0,
    @AmountRequested         MONEY          = NULL,
    @TotalAnticipated        MONEY          = NULL,
    @PercentAnticipated      FLOAT          = NULL,
    @RevenueDescriptionId    INT            = NULL,
    @IsEarlyStart            BIT            = 0,
    @EarlyStartReasonId      INT            = NULL,
    @EarlyStartReasonOther   NVARCHAR(MAX)  = NULL,
    @Company                 NVARCHAR(10)   = NULL,
    @IsEac                   NVARCHAR(5)    = NULL,
    @Revision                INT            = 0,
    @StartDate               DATETIME2      = NULL,
    @ExpirationDate          DATETIME2      = NULL,
    @ExportedAt              DATETIME2      = NULL,
    @NegatedAt               DATETIME2      = NULL,
    @CancelledAt             DATETIME2      = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Ara
    SET
        CategoryId              = @CategoryId,
        StatusId                = @StatusId,
        ProgramManagerId        = @ProgramManagerId,
        ContractAdministratorId = @ContractAdministratorId,
        ControllerId            = @ControllerId,
        OpsVpUserId             = @OpsVpUserId,
        Reference               = @Reference,
        JamisId                 = @JamisId,
        Division                = @Division,
        ContractNumber          = @ContractNumber,
        DeliveryOrderNumber     = @DeliveryOrderNumber,
        ContractType            = @ContractType,
        OmsNumber               = @OmsNumber,
        Title                   = @Title,
        CustomerName            = @CustomerName,
        AmountTotal             = @AmountTotal,
        AmountRequested         = @AmountRequested,
        TotalAnticipated        = @TotalAnticipated,
        PercentAnticipated      = @PercentAnticipated,
        RevenueDescriptionId    = @RevenueDescriptionId,
        IsEarlyStart            = @IsEarlyStart,
        EarlyStartReasonId      = @EarlyStartReasonId,
        EarlyStartReasonOther   = @EarlyStartReasonOther,
        Company                 = @Company,
        IsEac                   = @IsEac,
        Revision                = @Revision,
        StartDate               = @StartDate,
        ExpirationDate          = @ExpirationDate,
        ExportedAt              = @ExportedAt,
        NegatedAt               = @NegatedAt,
        CancelledAt             = @CancelledAt,
        UpdatedAt               = GETUTCDATE()
    WHERE AraId = @AraId;
END
GO

-- =============================================================================
-- APPROVAL LOG PROCEDURES
-- =============================================================================

CREATE OR ALTER PROCEDURE dbo.usp_AraApprovalLogGetByAraId
    @AraId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Columns aliased to match ApprovalRecord entity property names.
    -- Action is derived: IsRejection=1 → Reject(3), StatusId=5 → Approve(2), else Review(1).
    SELECT
        AraApprovalLogId AS ApprovalRecordId,
        AraId,
        UserId           AS ApproverId,
        JobTitleId,
        CASE
            WHEN IsRejection = 1 THEN 3
            WHEN StatusId    = 5 THEN 2
            ELSE 1
        END              AS Action,
        SequenceOrder,
        Comment,
        RejectionReasonId,
        RejectionAreas,
        ActionDate       AS ActionTakenAt,
        Cycle            AS AraRevision
    FROM dbo.AraApprovalLog
    WHERE AraId = @AraId
    ORDER BY Cycle, SequenceOrder, ActionDate;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_AraApprovalLogGetByAraIdAndRevision
    @AraId    INT,
    @Revision INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        AraApprovalLogId AS ApprovalRecordId,
        AraId,
        UserId           AS ApproverId,
        JobTitleId,
        CASE
            WHEN IsRejection = 1 THEN 3
            WHEN StatusId    = 5 THEN 2
            ELSE 1
        END              AS Action,
        SequenceOrder,
        Comment,
        RejectionReasonId,
        RejectionAreas,
        ActionDate       AS ActionTakenAt,
        Cycle            AS AraRevision
    FROM dbo.AraApprovalLog
    WHERE AraId = @AraId
      AND Cycle  = @Revision
    ORDER BY SequenceOrder, ActionDate;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_AraApprovalLogCreate
    @AraId             INT,
    @UserId            INT            = NULL,
    @JobTitleId        INT            = NULL,
    @StatusId          INT            = NULL,
    @IsRejection       BIT            = 0,
    @Comment           NVARCHAR(MAX)  = NULL,
    @Cycle             INT            = 0,
    @RejectionReasonId INT            = NULL,
    @RejectionAreas    NVARCHAR(100)  = NULL,
    @SequenceOrder     INT            = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.AraApprovalLog
    (
        AraId, UserId, JobTitleId, StatusId,
        IsRejection, Comment, ActionDate,
        Cycle, RejectionReasonId, RejectionAreas, SequenceOrder
    )
    VALUES
    (
        @AraId, @UserId, @JobTitleId, @StatusId,
        @IsRejection, @Comment, GETUTCDATE(),
        @Cycle, @RejectionReasonId, @RejectionAreas, @SequenceOrder
    );
END
GO

-- =============================================================================
-- ATTACHMENT PROCEDURES
-- =============================================================================

CREATE OR ALTER PROCEDURE dbo.usp_AraAttachmentGetByAraId
    @AraId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Columns aliased to match AraDocument entity property names.
    SELECT
        AraAttachmentId AS AraDocumentId,
        AraId,
        FileName,
        StoragePath,
        UploadedByUserId,
        UploadedAt
    FROM dbo.AraAttachment
    WHERE AraId = @AraId
    ORDER BY UploadedAt DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_AraAttachmentCreate
    @AraId            INT,
    @UploadedByUserId INT           = NULL,
    @FileName         NVARCHAR(260),
    @StoragePath      NVARCHAR(500),
    @FileSize         INT           = NULL,
    @MimeType         NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.AraAttachment
        (AraId, UploadedByUserId, FileName, StoragePath, FileSize, MimeType, UploadedAt)
    VALUES
        (@AraId, @UploadedByUserId, @FileName, @StoragePath, @FileSize, @MimeType, GETUTCDATE());

    SELECT SCOPE_IDENTITY() AS AraAttachmentId;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_AraAttachmentDelete
    @AraAttachmentId INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.AraAttachmentRequirementLink WHERE AraAttachmentId = @AraAttachmentId;
    DELETE FROM dbo.AraAttachment                WHERE AraAttachmentId = @AraAttachmentId;
END
GO

-- =============================================================================
-- CLIN PROCEDURES
-- =============================================================================

CREATE OR ALTER PROCEDURE dbo.usp_ClinGetByAraId
    @AraId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Columns aliased to match ClinEntry entity property names.
    -- Extra Clin table columns (ExpirationDate, RevisionAmount, etc.) are omitted;
    -- they exist in the DB for future use but are not yet part of the domain model.
    SELECT
        ClinId      AS ClinEntryId,
        AraId,
        ClinNumber,
        Description AS ClinDescription,
        CostFunding AS Cost,
        FeeFunding  AS Fee,
        CreatedAt,
        UpdatedAt
    FROM dbo.Clin
    WHERE AraId = @AraId
    ORDER BY ClinId;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_ClinCreate
    @AraId          INT,
    @ClinNumber     NVARCHAR(50),
    @Description    NVARCHAR(MAX) = NULL,
    @ExpirationDate DATETIME2     = NULL,
    @RevisionAmount MONEY         = NULL,
    @CostFunding    MONEY         = NULL,
    @FeeFunding     MONEY         = NULL,
    @CameFromJamis  BIT           = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Total MONEY = ISNULL(@CostFunding, 0) + ISNULL(@FeeFunding, 0);

    INSERT INTO dbo.Clin
        (AraId, ClinNumber, Description, ExpirationDate, RevisionAmount,
         CostFunding, FeeFunding, Total, CameFromJamis, IsNegated, CreatedAt, UpdatedAt)
    VALUES
        (@AraId, @ClinNumber, @Description, @ExpirationDate, @RevisionAmount,
         @CostFunding, @FeeFunding, @Total, @CameFromJamis, 0, GETUTCDATE(), GETUTCDATE());

    SELECT SCOPE_IDENTITY() AS ClinId;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_ClinUpdate
    @ClinId         INT,
    @ClinNumber     NVARCHAR(50)  = NULL,
    @Description    NVARCHAR(MAX) = NULL,
    @ExpirationDate DATETIME2     = NULL,
    @RevisionAmount MONEY         = NULL,
    @CostFunding    MONEY         = NULL,
    @FeeFunding     MONEY         = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Clin
    SET
        ClinNumber     = ISNULL(@ClinNumber, ClinNumber),
        Description    = @Description,
        ExpirationDate = @ExpirationDate,
        RevisionAmount = @RevisionAmount,
        CostFunding    = @CostFunding,
        FeeFunding     = @FeeFunding,
        Total          = ISNULL(@CostFunding, 0) + ISNULL(@FeeFunding, 0),
        UpdatedAt      = GETUTCDATE()
    WHERE ClinId = @ClinId;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_ClinDelete
    @ClinId INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.Clin WHERE ClinId = @ClinId;
END
GO

-- =============================================================================
-- ARA STATUS UPDATE (workflow transitions)
-- =============================================================================

CREATE OR ALTER PROCEDURE dbo.usp_AraUpdateStatus
    @AraId       INT,
    @StatusId    INT,
    @Revision    INT,
    @CancelledAt DATETIME2 = NULL,
    @NegatedAt   DATETIME2 = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Ara
    SET
        StatusId    = @StatusId,
        Revision    = @Revision,
        CancelledAt = @CancelledAt,
        NegatedAt   = @NegatedAt,
        UpdatedAt   = GETUTCDATE()
    WHERE AraId = @AraId;
END
GO

-- =============================================================================
-- PM SECTION PROCEDURES
-- =============================================================================

CREATE OR ALTER PROCEDURE dbo.usp_AraPmSectionGetByAraId
    @AraId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        AraPmSectionId, AraId,
        FundsInAdvance, ContractDefinization, PertinentInformation,
        WorkStarted, Consequence, CurrentStatus, ChangeInScope,
        ActionToClear, EarlyStartNecessary, OtherNecessary
    FROM dbo.AraPmSection
    WHERE AraId = @AraId;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_AraPmSectionUpsert
    @AraId                INT,
    @FundsInAdvance       NVARCHAR(MAX) = NULL,
    @ContractDefinization NVARCHAR(MAX) = NULL,
    @PertinentInformation NVARCHAR(MAX) = NULL,
    @WorkStarted          NVARCHAR(MAX) = NULL,
    @Consequence          NVARCHAR(MAX) = NULL,
    @CurrentStatus        NVARCHAR(MAX) = NULL,
    @ChangeInScope        NVARCHAR(MAX) = NULL,
    @ActionToClear        NVARCHAR(MAX) = NULL,
    @EarlyStartNecessary  NVARCHAR(MAX) = NULL,
    @OtherNecessary       NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    MERGE dbo.AraPmSection AS target
    USING (SELECT @AraId AS AraId) AS source (AraId)
    ON target.AraId = source.AraId
    WHEN MATCHED THEN
        UPDATE SET
            FundsInAdvance       = @FundsInAdvance,
            ContractDefinization = @ContractDefinization,
            PertinentInformation = @PertinentInformation,
            WorkStarted          = @WorkStarted,
            Consequence          = @Consequence,
            CurrentStatus        = @CurrentStatus,
            ChangeInScope        = @ChangeInScope,
            ActionToClear        = @ActionToClear,
            EarlyStartNecessary  = @EarlyStartNecessary,
            OtherNecessary       = @OtherNecessary
    WHEN NOT MATCHED THEN
        INSERT (
            AraId, FundsInAdvance, ContractDefinization, PertinentInformation,
            WorkStarted, Consequence, CurrentStatus, ChangeInScope,
            ActionToClear, EarlyStartNecessary, OtherNecessary
        )
        VALUES (
            @AraId, @FundsInAdvance, @ContractDefinization, @PertinentInformation,
            @WorkStarted, @Consequence, @CurrentStatus, @ChangeInScope,
            @ActionToClear, @EarlyStartNecessary, @OtherNecessary
        );
END
GO

-- =============================================================================
-- CONTROLLER SECTION PROCEDURES
-- =============================================================================

CREATE OR ALTER PROCEDURE dbo.usp_AraControllerSectionGetByAraId
    @AraId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        AraControllerSectionId, AraId, ControllerId,
        InterestImpact, BurnRate,
        TotalCost, TotalFee,
        IncurredCost, IncurredFee,
        Company
    FROM dbo.AraControllerSection
    WHERE AraId = @AraId;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_AraControllerSectionUpsert
    @AraId         INT,
    @ControllerId  INT           = NULL,
    @InterestImpact FLOAT        = NULL,
    @BurnRate      FLOAT         = NULL,
    @IncurredCost  FLOAT         = NULL,
    @IncurredFee   FLOAT         = NULL,
    @Company       NVARCHAR(10)  = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Auto-calculate totals from current CLIN entries for this ARA.
    DECLARE @TotalCost FLOAT = (
        SELECT ISNULL(SUM(CAST(CostFunding AS FLOAT)), 0)
        FROM dbo.Clin
        WHERE AraId = @AraId AND IsNegated = 0
    );

    DECLARE @TotalFee FLOAT = (
        SELECT ISNULL(SUM(CAST(FeeFunding AS FLOAT)), 0)
        FROM dbo.Clin
        WHERE AraId = @AraId AND IsNegated = 0
    );

    MERGE dbo.AraControllerSection AS target
    USING (SELECT @AraId AS AraId) AS source (AraId)
    ON target.AraId = source.AraId
    WHEN MATCHED THEN
        UPDATE SET
            ControllerId   = ISNULL(@ControllerId, target.ControllerId),
            InterestImpact = @InterestImpact,
            BurnRate       = @BurnRate,
            TotalCost      = @TotalCost,
            TotalFee       = @TotalFee,
            IncurredCost   = @IncurredCost,
            IncurredFee    = @IncurredFee,
            Company        = @Company
    WHEN NOT MATCHED THEN
        INSERT (
            AraId, ControllerId,
            InterestImpact, BurnRate,
            TotalCost, TotalFee,
            IncurredCost, IncurredFee,
            Company
        )
        VALUES (
            @AraId, @ControllerId,
            @InterestImpact, @BurnRate,
            @TotalCost, @TotalFee,
            @IncurredCost, @IncurredFee,
            @Company
        );
END
GO

PRINT 'Stored procedures migration 003_stored_procedures.sql complete.';
GO
