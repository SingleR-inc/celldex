# This tests the fetching of reference datasets.
# library(testthat); library(celldex); source("test-fetchReference.R")

test_that("fetchReference works as expected", {
    sce <- fetchReference("hpca", "2024-02-26")
    expect_s4_class(sce, "SummarizedExperiment")

    # Correctly creates ReloadedMatrix objects.
    ass <- assay(sce, withDimnames=FALSE)
    expect_s4_class(ass, "ReloadedMatrix")
    expect_false(DelayedArray::is_sparse(ass))
    expect_true(grepl("hpca", ass@seed@path))
    expect_true(grepl("2024-02-26", ass@seed@path))

    # Works with realization options.
    sce <- fetchReference("hpca", "2024-02-26", realize.assays=TRUE)
    expect_type(assay(sce, withDimnames=FALSE), "double")
})

test_that("fetchMetadata works as expected", {
    meta <- fetchMetadata("hpca", "2024-02-26")
    expect_match(meta$title, "Human Primary Cell Atlas")
    expect_identical(meta$taxonomy_id[[1]], "9606")
})
