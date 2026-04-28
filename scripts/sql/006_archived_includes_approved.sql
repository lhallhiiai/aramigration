-- =============================================================================
-- Update Archived Query to Include Approved ARAs
-- Script:  006_archived_includes_approved.sql
-- Purpose: Since JAMIS export is OBE, ARAs will never reach Exported status.
--          The Archived view now includes Approved ARAs so the CA can negate
--          them when a contract modification is received.
-- =============================================================================

SET NOCOUNT ON;
GO

CREATE OR ALTER PROCEDURE dbo.usp_AraGetArchived
AS
BEGIN
    SET NOCOUNT ON;

    -- Approved, Exported, and Negated ARAs accessible from the Archived menu.
    -- Approved included because JAMIS export is OBE — Approved is the terminal
    -- positive status, and CAs need to negate Approved ARAs.
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
    WHERE StatusId IN (5, 6, 8) -- Approved = 5, Exported = 6, Negated = 8
    ORDER BY ISNULL(ExportedAt, ISNULL(NegatedAt, UpdatedAt)) DESC;
END
GO

PRINT 'Migration 006_archived_includes_approved.sql complete.';
GO
