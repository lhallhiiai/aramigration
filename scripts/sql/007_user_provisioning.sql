-- =============================================================================
-- ARA Database Migration
-- Script:  007_user_provisioning.sql
-- Purpose: Add usp_UserProvision so that authenticated Okta users without a
--          local row can be created automatically (JIT) on first sign-in,
--          and so an admin endpoint can pre-seed users for background
--          processes that need a row before any sign-in.
--          Idempotent: re-running is safe (CREATE OR ALTER) and the SP
--          itself is idempotent on the User table (no-op when the user
--          already exists).
-- =============================================================================

SET NOCOUNT ON;
GO

-- -----------------------------------------------------------------------------
-- usp_UserProvision
-- Inserts a new User row when no row exists for the given ExternalUserId.
-- Always returns the row that ends up in the table (existing or newly created),
-- shaped to match dbo.[User] so Dapper can map it to the User entity.
--
-- Default RoleId = 1 (Creator/PM) matches the existing dev-user precedent in
-- Invoke-AraDataMigration.ps1. Roles can be elevated by an admin via direct
-- SQL or a future user-management endpoint; the role assignment story is out
-- of scope for Item 4.
-- -----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.usp_UserProvision
    @ExternalUserId NVARCHAR(100),
    @Email          NVARCHAR(255),
    @DisplayName    NVARCHAR(500),
    @FirstName      NVARCHAR(100) = NULL,
    @LastName       NVARCHAR(100) = NULL,
    @RoleId         INT           = 1
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 FROM dbo.[User] WHERE ExternalUserId = @ExternalUserId
    )
    BEGIN
        INSERT INTO dbo.[User] (
            ExternalUserId,
            Email,
            DisplayName,
            FirstName,
            LastName,
            RoleId,
            IsInactive,
            CreatedAt
        )
        VALUES (
            @ExternalUserId,
            @Email,
            @DisplayName,
            @FirstName,
            @LastName,
            @RoleId,
            0,
            GETUTCDATE()
        );
    END;

    SELECT
        UserId,
        ExternalUserId,
        EmployeeId,
        LegacyOprid,
        DisplayName,
        FirstName,
        LastName,
        Email,
        RoleId,
        JobTitleId,
        SectorId,
        ApprovalGroups,
        ApprovalOperation,
        ApprovalDivision,
        IsInactive,
        CreatedAt,
        UpdatedAt
    FROM dbo.[User]
    WHERE ExternalUserId = @ExternalUserId;
END
GO
