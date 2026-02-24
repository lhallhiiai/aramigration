-- =============================================================================
-- ARA Reference Data Seed
-- Script:  002_seed_data.sql
-- Purpose: Populate lookup tables with reference data.
--          Idempotent: uses MERGE or INSERT WHERE NOT EXISTS.
-- =============================================================================

SET NOCOUNT ON;
GO

-- =============================================================================
-- Role  (IDs align with ARA.Domain.Enums.UserRole)
-- =============================================================================
MERGE dbo.Role AS target
USING (VALUES
    (1, 'Creator',                  'PM',   'Creates ARAs and completes the Program Manager section'),
    (2, 'Contract Administrator',   'CA',   'Reviews after PM, uploads documents, submits or rejects'),
    (3, 'Controller',               'CON',  'Completes CLIN worksheet (Non-Early Start), submits for approval'),
    (4, 'Approver',                 'APP',  'Reviews and approves or rejects per the Approval Threshold Matrix')
) AS source (RoleId, RoleName, RoleShort, RoleDesc)
ON target.RoleId = source.RoleId
WHEN MATCHED THEN
    UPDATE SET RoleName = source.RoleName, RoleShort = source.RoleShort, RoleDesc = source.RoleDesc
WHEN NOT MATCHED THEN
    INSERT (RoleName, RoleShort, RoleDesc)
    VALUES (source.RoleName, source.RoleShort, source.RoleDesc);
GO

-- =============================================================================
-- JobTitle  (IDs must match legacy jobTitle.id_job; CA=2, Controller=3, PM=4)
-- AppOrder drives the sequential approval chain for approver-level roles.
-- =============================================================================
MERGE dbo.JobTitle AS target
USING (VALUES
    (1,  'Program Manager',          NULL,  'Program Manager responsible for the ARA',                  0),
    (2,  'Contract Administrator',   NULL,  'Contract Administrator who reviews after PM submission',   0),
    (3,  'Controller',               NULL,  'Controller who reviews after CA and completes CLIN work',  0),
    (4,  'Program Manager (Approver)', NULL,'Program Manager in approver chain',                        0),
    (5,  'Group Contracts Manager',  1,    'Group-level Contracts Manager approver',                   0),
    (6,  'Group Controller',         2,    'Group-level Controller approver',                          0),
    (7,  'Division Manager',         3,    'Division Manager approver',                                0),
    (8,  'Operations Manager',       4,    'Operations Manager approver',                              0),
    (9,  'Group Manager',            5,    'Group Manager approver',                                   0),
    (10, 'Sector Contracts Manager', 6,    'Sector-level Contracts Manager approver',                  0),
    (11, 'Sector Controller',        7,    'Sector-level Controller approver',                         0),
    (12, 'Sector Manager',           8,    'Sector Manager approver',                                  0),
    (13, 'CAO',                      9,    'Chief Accounting Officer approver',                        0),
    (14, 'CFO',                      10,   'Chief Financial Officer approver',                         0),
    (15, 'COO',                      11,   'Chief Operating Officer approver',                         0),
    (16, 'CEO',                      12,   'Chief Executive Officer approver',                         0)
) AS source (JobTitleId, Title, AppOrder, Description, IsInactive)
ON target.JobTitleId = source.JobTitleId
WHEN MATCHED THEN
    UPDATE SET Title = source.Title, AppOrder = source.AppOrder,
               Description = source.Description, IsInactive = source.IsInactive
WHEN NOT MATCHED THEN
    INSERT (JobTitleId, Title, AppOrder, Description, IsInactive)
    VALUES (source.JobTitleId, source.Title, source.AppOrder, source.Description, source.IsInactive);
GO
-- Note: JobTitle has no identity column (IDs are fixed legacy values that drive approval routing).
-- DBCC CHECKIDENT does not apply here.

-- =============================================================================
-- Status  (IDs align with ARA.Domain.Enums.AraStatus)
-- =============================================================================
MERGE dbo.Status AS target
USING (VALUES
    (1, 'Draft',                              'Draft'),
    (2, 'Pending Contract Administrator',     'Pending CA'),
    (3, 'Pending Controller',                 'Pending Controller'),
    (4, 'Pending Approval',                   'Pending Approval'),
    (5, 'Approved',                           'Approved'),
    (6, 'Exported',                           'Exported'),
    (7, 'Expired',                            'Expired'),
    (8, 'Negated',                            'Negated'),
    (9, 'Cancelled',                          'Cancelled')
) AS source (StatusId, StatusName, OneWord)
ON target.StatusId = source.StatusId
WHEN MATCHED THEN
    UPDATE SET StatusName = source.StatusName, OneWord = source.OneWord
WHEN NOT MATCHED THEN
    INSERT (StatusName, OneWord)
    VALUES (source.StatusName, source.OneWord);
GO

-- Re-seed identity after manual inserts
DBCC CHECKIDENT ('dbo.Status', RESEED, 100);
GO

-- =============================================================================
-- Category  (IDs align with ARA.Domain.Enums.RiskCategory)
-- RiskLevel groups categories for threshold matching; current data uses 1:1 mapping.
-- Color values are placeholders — confirm with UI design.
-- =============================================================================
MERGE dbo.Category AS target
USING (VALUES
    (1, 'Award Fees',                             1, '#FF6B6B'),
    (2, 'Mod Pending (Incremental Funding)',       2, '#4ECDC4'),
    (3, 'Mod Pending (Exercise Option Period)',    3, '#45B7D1'),
    (4, 'Mod Pending (Not Exercise Option Period)',4, '#96CEB4'),
    (5, 'Internal Cleared',                       5, '#FFEAA7'),
    (6, 'Commercial At-Risk',                     6, '#DDA0DD'),
    (7, 'Change in Scope',                        7, '#98D8C8'),
    (8, 'Fixed Price Mod',                        8, '#F7DC6F'),
    (9, 'Pre-Contract Costs (Early Start)',        9, '#BB8FCE')
) AS source (CategoryId, CategoryName, RiskLevel, Color)
ON target.CategoryId = source.CategoryId
WHEN MATCHED THEN
    UPDATE SET CategoryName = source.CategoryName, RiskLevel = source.RiskLevel, Color = source.Color
WHEN NOT MATCHED THEN
    INSERT (CategoryName, RiskLevel, Color)
    VALUES (source.CategoryName, source.RiskLevel, source.Color);
GO

DBCC CHECKIDENT ('dbo.Category', RESEED, 100);
GO

-- =============================================================================
-- EarlyStartReason
-- =============================================================================
IF NOT EXISTS (SELECT 1 FROM dbo.EarlyStartReason WHERE EarlyStartReasonId = 1)
BEGIN
    SET IDENTITY_INSERT dbo.EarlyStartReason ON;
    INSERT INTO dbo.EarlyStartReason (EarlyStartReasonId, Reason) VALUES
        (1, 'Customer written authorization'),
        (2, 'Verbal authorization with written follow-up'),
        (3, 'Other');
    SET IDENTITY_INSERT dbo.EarlyStartReason OFF;
END
GO

-- =============================================================================
-- RevenueDescription
-- =============================================================================
IF NOT EXISTS (SELECT 1 FROM dbo.RevenueDescription WHERE RevenueDescriptionId = 1)
BEGIN
    SET IDENTITY_INSERT dbo.RevenueDescription ON;
    INSERT INTO dbo.RevenueDescription (RevenueDescriptionId, Description) VALUES
        (1, 'Authority to Spend Only'),
        (2, 'Authority to Spend and Recognize Revenue');
    SET IDENTITY_INSERT dbo.RevenueDescription OFF;
END
GO

-- =============================================================================
-- RejectionReason
-- =============================================================================
IF NOT EXISTS (SELECT 1 FROM dbo.RejectionReason)
BEGIN
    INSERT INTO dbo.RejectionReason (Reason, Description) VALUES
        ('Incomplete Information',    'The ARA is missing required fields or supporting documentation'),
        ('Amount Discrepancy',        'The requested amount does not match supporting documentation'),
        ('Incorrect Risk Category',   'The selected risk category does not match the described situation'),
        ('Contract Issue',            'The referenced contract number is incorrect or invalid'),
        ('Policy Non-Compliance',     'The ARA does not comply with company policy'),
        ('Other',                     'See comment for details');
END
GO

-- =============================================================================
-- EmailType
-- =============================================================================
IF NOT EXISTS (SELECT 1 FROM dbo.EmailType)
BEGIN
    INSERT INTO dbo.EmailType (EmailType, LongDescription) VALUES
        ('PM_SUBMITTED',         'PM has signed and submitted the ARA'),
        ('CA_SUBMITTED',         'Contract Administrator has submitted the ARA for next approval'),
        ('CONTROLLER_SUBMITTED', 'Controller has submitted the ARA for approval'),
        ('APPROVER_APPROVED',    'An approver has approved the ARA'),
        ('REJECTED',             'The ARA has been rejected and returned to the PM'),
        ('NEGATED',              'The ARA has been negated by the Contract Administrator');
END
GO

-- =============================================================================
-- AttachmentRequirement (document checklist items)
-- Exact list must be confirmed with product owner.
-- Non-Early Start CA requirements are marked who = 'CA'.
-- Non-Early Start Controller requirements are marked who = 'Controller'.
-- =============================================================================
IF NOT EXISTS (SELECT 1 FROM dbo.AttachmentRequirement)
BEGIN
    INSERT INTO dbo.AttachmentRequirement (CategoryIdList, ShortDescription, LongDescription, DisplayOrder, ApplicableRole) VALUES
        ('1,2,3,4,5,6,7,8', '75% Letter',              'Limitation of Funds / 75% Letter submitted to customer',         1, 'CA'),
        ('1,2,3,4,5,6,7,8', 'Modification Request',    'Formal modification request submitted to customer',               2, 'CA'),
        ('1,2,3,4,5,6,7,8', 'Customer Written Auth',   'Written customer authorization to proceed',                      3, 'CA'),
        ('1,2,3,4,5,6,7,8', 'Contract Documentation',  'Relevant contract documentation',                                4, 'Controller'),
        ('1,2,3,4,5,6,7,8', 'Cost Estimate',           'Supporting cost estimate documentation',                         5, 'Controller');
END
GO

-- =============================================================================
-- Dev User  (matches DevAuthenticationHandler claim "dev-user-00000000")
-- Allows local development without Azure Entra ID.
-- =============================================================================
IF NOT EXISTS (SELECT 1 FROM dbo.[User] WHERE EntraObjectId = N'dev-user-00000000')
BEGIN
    INSERT INTO dbo.[User]
        (EntraObjectId, DisplayName, FirstName, LastName, Email, RoleId, JobTitleId, IsInactive)
    VALUES
        (N'dev-user-00000000', N'Dev User', N'Dev', N'User', N'dev@local.dev', 1, 1, 0);
END
GO

PRINT 'Seed data migration 002_seed_data.sql complete.';
GO
