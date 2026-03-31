-- =============================================================================
-- ARA Database Migration
-- Script:  004_rename_entra_column.sql
-- Purpose: Rename EntraObjectId column to ExternalUserId on the User table
--          to reflect the switch from Microsoft Entra ID to Okta authentication.
--          Idempotent: checks for column existence before renaming.
--          Also drops the legacy usp_UserGetByEntraObjectId stored procedure.
-- =============================================================================

SET NOCOUNT ON;
GO

-- Rename column if it still has the old name
IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.[User]')
      AND name = 'EntraObjectId'
)
BEGIN
    EXEC sp_rename 'dbo.[User].EntraObjectId', 'ExternalUserId', 'COLUMN';
    PRINT 'Renamed EntraObjectId to ExternalUserId on dbo.[User]';
END
ELSE
BEGIN
    PRINT 'Column already renamed or does not exist — skipping.';
END
GO

-- Drop the legacy stored procedure if it still exists
IF OBJECT_ID('dbo.usp_UserGetByEntraObjectId', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.usp_UserGetByEntraObjectId;
    PRINT 'Dropped legacy procedure usp_UserGetByEntraObjectId';
END
GO
