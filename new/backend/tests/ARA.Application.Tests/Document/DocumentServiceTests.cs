using ARA.Application.Common;
using ARA.Application.Document;
using ARA.Domain.Entities;
using ARA.Domain.Repositories;
using FluentAssertions;
using Microsoft.Extensions.Logging;
using Moq;

namespace ARA.Application.Tests.Document;

/// <summary>
/// Tests for <see cref="DocumentService"/> covering document retrieval, creation, and deletion.
/// </summary>
public sealed class DocumentServiceTests
{
    private readonly Mock<IDocumentRepository> _documentRepo = new();
    private readonly DocumentService _sut;

    public DocumentServiceTests()
    {
        _sut = new DocumentService(
            _documentRepo.Object,
            Mock.Of<ILogger<DocumentService>>());
    }

    [Fact]
    public async Task GetByAraIdAsync_WithDocuments_ReturnsMappedDtos()
    {
        DateTime uploadTime = new(2026, 4, 15, 10, 30, 0, DateTimeKind.Utc);
        List<AraDocument> documents =
        [
            new()
            {
                AraDocumentId = 1, AraId = 100, FileName = "contract.pdf",
                StoragePath = "/uploads/contract.pdf", UploadedByUserId = 5, UploadedAt = uploadTime,
            },
            new()
            {
                AraDocumentId = 2, AraId = 100, FileName = "support.pdf",
                StoragePath = "/uploads/support.pdf", UploadedByUserId = 5, UploadedAt = uploadTime,
            },
        ];
        _documentRepo.Setup(r => r.GetByAraIdAsync(100, It.IsAny<CancellationToken>()))
            .ReturnsAsync(documents.AsReadOnly());

        IReadOnlyList<AraDocumentDto> result = await _sut.GetByAraIdAsync(100, CancellationToken.None);

        result.Should().HaveCount(2);
        result[0].AraDocumentId.Should().Be(1);
        result[0].AraId.Should().Be(100);
        result[0].FileName.Should().Be("contract.pdf");
        result[0].StoragePath.Should().Be("/uploads/contract.pdf");
        result[0].UploadedByUserId.Should().Be(5);
        result[0].UploadedAt.Should().Be(uploadTime);
    }

    [Fact]
    public async Task CreateAsync_WithValidRequest_ReturnsSuccessWithId()
    {
        int expectedId = 42;
        _documentRepo.Setup(r => r.CreateAsync(It.IsAny<AraDocument>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(expectedId);

        CreateDocumentRequest request = new("proposal.pdf", "/uploads/proposal.pdf");

        Result<int> result = await _sut.CreateAsync(100, 5, request, CancellationToken.None);

        result.IsSuccess.Should().BeTrue();
        result.Value.Should().Be(expectedId);
        _documentRepo.Verify(
            r => r.CreateAsync(
                It.Is<AraDocument>(d =>
                    d.AraId == 100 &&
                    d.UploadedByUserId == 5 &&
                    d.FileName == "proposal.pdf" &&
                    d.StoragePath == "/uploads/proposal.pdf"),
                It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task DeleteAsync_WithExistingDocument_ReturnsSuccess()
    {
        _documentRepo.Setup(r => r.DeleteAsync(1, It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        Result result = await _sut.DeleteAsync(1, CancellationToken.None);

        result.IsSuccess.Should().BeTrue();
        _documentRepo.Verify(r => r.DeleteAsync(1, It.IsAny<CancellationToken>()), Times.Once);
    }
}
