# This tests the fetching of reference datasets.
# library(testthat); library(celldex); source("test-listReferences.R")

test_that("listReferences works as expected", {
    refs <- listReferences()
    expect_true("hpca" %in% refs)
    expect_true("immgen" %in% refs)
    expect_true("monaco_immune" %in% refs)
})

test_that("listVersions works as expected", {
    versions <- listVersions("immgen")
    expect_true("2024-02-26" %in% versions)
    latest <- fetchLatestVersion("immgen")
    expect_true(latest %in% versions)
})
