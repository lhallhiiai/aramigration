-- =============================================================================
-- Approval Matrix, Delegation, and Rejection Reason Support
-- Script:  005_approval_delegation_rejection.sql
-- Purpose: 1. Schema alignment — add missing columns to Threshold, Delegation,
--             and RejectionReason tables so domain entities map cleanly via Dapper.
--          2. Seed the Approval & Threshold Matrix with the 10-role chain from
--             the user guide.
--          3. Replace generic RejectionReason seed data with the 7 codes from
--             the user guide.
--          4. Create stored procedures for ApprovalMatrix, Delegation, and
--             RejectionReason repositories.
--          Idempotent: uses IF NOT EXISTS checks and CREATE OR ALTER.
-- =============================================================================

SET NOCOUNT ON;
GO

-- =============================================================================
-- SCHEMA ALIGNMENT: Threshold table
-- Add SequenceOrder (maps to ApprovalMatrixEntry.SequenceOrder)
-- Add IsInactive flag for soft-delete
-- =============================================================================

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.Threshold')
      AND name = 'SequenceOrder'
)
BEGIN
    ALTER TABLE dbo.Threshold ADD SequenceOrder INT NULL;
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.Threshold')
      AND name = 'IsInactive'
)
BEGIN
    ALTER TABLE dbo.Threshold ADD IsInactive BIT NOT NULL CONSTRAINT DF_Threshold_IsInactive DEFAULT 0;
END
GO

-- =============================================================================
-- SCHEMA ALIGNMENT: RejectionReason table
-- Add DisplayOrder and IsInactive columns to match domain entity
-- =============================================================================

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.RejectionReason')
      AND name = 'DisplayOrder'
)
BEGIN
    ALTER TABLE dbo.RejectionReason ADD DisplayOrder INT NOT NULL CONSTRAINT DF_RejectionReason_DisplayOrder DEFAULT 0;
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.RejectionReason')
      AND name = 'IsInactive'
)
BEGIN
    ALTER TABLE dbo.RejectionReason ADD IsInactive BIT NOT NULL CONSTRAINT DF_RejectionReason_IsInactive DEFAULT 0;
END
GO

-- =============================================================================
-- SEED: Approval & Threshold Matrix (10-role sequential chain)
--
-- Maps the CLAUDE.md Approval & Threshold Matrix to the Threshold table.
-- SequenceOrder 1-3 are display-only (PM, CA, Controller).
-- SequenceOrder 4-10 are processed by the routing engine.
-- Steps 4-7: active for all ARAs (LowThreshold=0).
-- Steps 8-10: active only for ARAs >= $500,000.
--
-- JobTitleId values must match the JobTitle seed data from 002_seed_data.sql.
-- ReviewApprove: 'Approve' or 'Review' per the matrix specification.
-- =============================================================================

-- Clear existing threshold data and re-seed
DELETE FROM dbo.Threshold;
GO

-- Reset identity
DBCC CHECKIDENT ('dbo.Threshold', RESEED, 0);
GO

INSERT INTO dbo.Threshold
    (RiskLevel, JobTitleId, LowThreshold, HighThreshold, ReviewApprove, CanDelegate, SequenceOrder, IsInactive)
VALUES
    -- Display-only rows (SequenceOrder 1-3, not processed by routing engine)
    (NULL, 1,  NULL,    NULL,    'Create',  0, 1,  0),  -- PM (Creator)
    (NULL, 2,  0,       NULL,    'Approve', 1, 2,  0),  -- Contract Administrator
    (NULL, 3,  0,       NULL,    'Approve', 1, 3,  0),  -- Controller

    -- Routing engine rows (SequenceOrder 4-10)
    (NULL, 7,  0,       NULL,    'Approve', 1, 4,  0),  -- Portfolio Leader (Division Manager)
    (NULL, 5,  0,       NULL,    'Review',  1, 5,  0),  -- Contract Director (Group Contracts Manager)
    (NULL, 6,  0,       NULL,    'Review',  1, 6,  0),  -- Group Finance Manager (Group Controller)
    (NULL, 9,  0,       NULL,    'Approve', 1, 7,  0),  -- Business Group President (Group Manager)
    (NULL, 14, 500000,  NULL,    'Approve', 1, 8,  0),  -- Finance Vice President (CFO)
    (NULL, 10, 500000,  NULL,    'Review',  1, 9,  0),  -- SVP of Contracts & Procurement (Sector Contracts Manager)
    (NULL, 15, 500000,  NULL,    'Approve', 1, 10, 0);  -- MTC COO (COO)
GO

-- =============================================================================
-- SEED: RejectionReason — replace generic reasons with the 7 from user guide
-- =============================================================================

DELETE FROM dbo.RejectionReason;
GO

-- Reset identity
DBCC CHECKIDENT ('dbo.RejectionReason', RESEED, 0);
GO

INSERT INTO dbo.RejectionReason (Reason, Description, DisplayOrder, IsInactive) VALUES
    ('Insufficient Documentation',    'Supporting Documentation is Insufficient',      1, 0),
    ('Incorrect CLIN',                'Incorrect CLIN Number Used',                    2, 0),
    ('Incorrect Amount',              'Incorrect Amount Entered',                      3, 0),
    ('Amount Docs Mismatch',          'Amount & Supporting docs do not match',         4, 0),
    ('Inadequate Justification',      'Inadequate comments justification on form',     5, 0),
    ('Other',                         'Other',                                         6, 0),
    ('No Longer Needed',              'ARA no longer needed',                          7, 0);
GO

-- =============================================================================
-- STORED PROCEDURES: Approval Matrix
-- =============================================================================

CREATE OR ALTER PROCEDURE dbo.usp_ApprovalMatrixGetActive
AS
BEGIN
    SET NOCOUNT ON;

    -- Returns all active matrix entries including display rows (SequenceOrder 1-3).
    -- Column aliases map Threshold table columns to ApprovalMatrixEntry entity properties.
    SELECT
        t.ThresholdId     AS ApprovalMatrixEntryId,
        t.SequenceOrder,
        jt.Title          AS RoleName,
        t.JobTitleId,
        CASE t.ReviewApprove
            WHEN 'Approve' THEN 2  -- ApprovalActionType.Approve
            WHEN 'Review'  THEN 1  -- ApprovalActionType.Review
            ELSE 0
        END               AS RequiredAction,
        ISNULL(t.LowThreshold, 0) AS MinimumAmount,
        ISNULL(t.CanDelegate, 0)  AS IsDelegable,
        t.IsInactive
    FROM dbo.Threshold t
    INNER JOIN dbo.JobTitle jt ON jt.JobTitleId = t.JobTitleId
    WHERE t.IsInactive = 0
    ORDER BY t.SequenceOrder;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_ApprovalMatrixGetForAmount
    @Amount MONEY
AS
BEGIN
    SET NOCOUNT ON;

    -- Returns only routing-engine entries (SequenceOrder >= 4) where the ARA
    -- amount meets or exceeds the step's minimum threshold. Ordered by
    -- SequenceOrder for sequential processing.
    SELECT
        t.ThresholdId     AS ApprovalMatrixEntryId,
        t.SequenceOrder,
        jt.Title          AS RoleName,
        t.JobTitleId,
        CASE t.ReviewApprove
            WHEN 'Approve' THEN 2
            WHEN 'Review'  THEN 1
            ELSE 0
        END               AS RequiredAction,
        ISNULL(t.LowThreshold, 0) AS MinimumAmount,
        ISNULL(t.CanDelegate, 0)  AS IsDelegable,
        t.IsInactive
    FROM dbo.Threshold t
    INNER JOIN dbo.JobTitle jt ON jt.JobTitleId = t.JobTitleId
    WHERE t.IsInactive = 0
      AND t.SequenceOrder >= 4
      AND ISNULL(t.LowThreshold, 0) <= @Amount
    ORDER BY t.SequenceOrder;
END
GO

-- =============================================================================
-- STORED PROCEDURES: Delegation
--
-- The Delegation table uses DelegateFromId/DelegateToId columns.
-- These SPs alias them to DelegatorUserId/DelegateeUserId for the domain entity.
-- IsActive is computed: StartDate <= GETUTCDATE() AND EndDate >= GETUTCDATE()
-- and the record has not been soft-deactivated (EndDate not set to past).
-- =============================================================================

CREATE OR ALTER PROCEDURE dbo.usp_DelegationGetActiveForUser
    @DelegatorUserId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 1
        DelegationId,
        DelegateFromId AS DelegatorUserId,
        DelegateToId   AS DelegateeUserId,
        StartDate,
        EndDate,
        CAST(1 AS BIT) AS IsActive,
        CreatedAt
    FROM dbo.Delegation
    WHERE DelegateFromId = @DelegatorUserId
      AND StartDate <= GETUTCDATE()
      AND EndDate   >= GETUTCDATE()
    ORDER BY CreatedAt DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_DelegationGetActiveForDelegatee
    @DelegateeUserId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        DelegationId,
        DelegateFromId AS DelegatorUserId,
        DelegateToId   AS DelegateeUserId,
        StartDate,
        EndDate,
        CAST(1 AS BIT) AS IsActive,
        CreatedAt
    FROM dbo.Delegation
    WHERE DelegateToId = @DelegateeUserId
      AND StartDate <= GETUTCDATE()
      AND EndDate   >= GETUTCDATE()
    ORDER BY CreatedAt DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_DelegationGetAllActive
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        DelegationId,
        DelegateFromId AS DelegatorUserId,
        DelegateToId   AS DelegateeUserId,
        StartDate,
        EndDate,
        CAST(1 AS BIT) AS IsActive,
        CreatedAt
    FROM dbo.Delegation
    WHERE StartDate <= GETUTCDATE()
      AND EndDate   >= GETUTCDATE()
    ORDER BY CreatedAt DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_DelegationCreate
    @DelegatorUserId INT,
    @DelegateeUserId INT,
    @StartDate       DATETIME2,
    @EndDate         DATETIME2
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Delegation
        (DelegateFromId, DelegateToId, StartDate, EndDate, CreatedAt)
    VALUES
        (@DelegatorUserId, @DelegateeUserId, @StartDate, @EndDate, GETUTCDATE());

    SELECT SCOPE_IDENTITY() AS DelegationId;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_DelegationDeactivate
    @DelegationId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Soft-deactivate by setting EndDate to current UTC time.
    -- This makes the delegation fall out of all "active" queries.
    UPDATE dbo.Delegation
    SET EndDate   = GETUTCDATE(),
        UpdatedAt = GETUTCDATE()
    WHERE DelegationId = @DelegationId;
END
GO

-- =============================================================================
-- STORED PROCEDURES: Rejection Reason
-- =============================================================================

CREATE OR ALTER PROCEDURE dbo.usp_RejectionReasonGetAllActive
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        RejectionReasonId,
        Description,
        DisplayOrder,
        IsInactive
    FROM dbo.RejectionReason
    WHERE IsInactive = 0
    ORDER BY DisplayOrder;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_RejectionReasonGetById
    @RejectionReasonId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        RejectionReasonId,
        Description,
        DisplayOrder,
        IsInactive
    FROM dbo.RejectionReason
    WHERE RejectionReasonId = @RejectionReasonId;
END
GO

-- =============================================================================
-- STORED PROCEDURE: Bulk expire overdue ARAs
-- Used by the AraExpirationHostedService (runs hourly).
-- =============================================================================

CREATE OR ALTER PROCEDURE dbo.usp_AraExpireOverdue
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ExpiredStatusId INT = 7; -- AraStatus.Expired

    UPDATE dbo.Ara
    SET StatusId  = @ExpiredStatusId,
        UpdatedAt = GETUTCDATE()
    WHERE ExpirationDate < GETUTCDATE()
      AND StatusId IN (1, 2, 3, 4)  -- Draft, PendingCA, PendingController, PendingApproval
      AND CancelledAt IS NULL
      AND NegatedAt IS NULL;

    -- Return count of expired ARAs for logging
    SELECT @@ROWCOUNT AS ExpiredCount;
END
GO

-- =============================================================================
-- SCHEMA ALIGNMENT: EmailLog table
-- Add Body and SentByUserId columns for the LoggingEmailService.
-- Existing Recipients column is used for ToAddress; CcRecipients stays.
-- =============================================================================

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.EmailLog')
      AND name = 'Body'
)
BEGIN
    ALTER TABLE dbo.EmailLog ADD Body NVARCHAR(MAX) NULL;
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.EmailLog')
      AND name = 'SentByUserId'
)
BEGIN
    ALTER TABLE dbo.EmailLog ADD SentByUserId INT NULL;
END
GO

-- =============================================================================
-- STORED PROCEDURE: Email log creation
-- Used by LoggingEmailService to persist email records.
-- =============================================================================

CREATE OR ALTER PROCEDURE dbo.usp_EmailLogCreate
    @AraId        INT            = NULL,
    @EmailTypeId  INT            = NULL,
    @Recipients   NVARCHAR(500),
    @CcRecipients NVARCHAR(500)  = NULL,
    @Subject      NVARCHAR(MAX),
    @Body         NVARCHAR(MAX)  = NULL,
    @SentByUserId INT            = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.EmailLog
        (AraId, EmailTypeId, Recipients, CcRecipients, Subject, Body, SentByUserId, SentAt)
    VALUES
        (@AraId, @EmailTypeId, @Recipients, @CcRecipients, @Subject, @Body, @SentByUserId, GETUTCDATE());

    SELECT SCOPE_IDENTITY() AS EmailLogId;
END
GO

PRINT 'Migration 005_approval_delegation_rejection.sql complete.';
GO
