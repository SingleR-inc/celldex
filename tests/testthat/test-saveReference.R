# This checks that saveReference works as expected.
# library(testthat); library(celldex); source("test-saveReference.R")

# Mocking up some data to be saved.
x <- matrix(rnorm(1000), ncol=10)
rownames(x) <- sprintf("GENE_%i", seq_len(nrow(x)))
labels <- DataFrame(
    labels.broad = sample(c("B", "T", "NK"), ncol(x), replace=TRUE),
    labels.fine = sample(c("PC", "pre-B", "pro-B", "Th2", "CD4+T", "NK"), 
        ncol(x), replace=TRUE)
)
                                                                                    
test_that("saveReference works as expected", {
    meta <- list(
        title="My dataset",
        description="This is my dataset",
        taxonomy_id="10090",
        genome="GRCh38",
        sources=list(list(provider="GEO", id="GSE12345")),
        maintainer_name="Shizuka Mogami",
        maintainer_email="mogami.shizuka@765pro.com"
    )

    tmp <- tempfile()
    saveReference(x, labels, tmp, meta)
                                                                                        
    se <- alabaster.base::readObject(tmp)
    expect_s4_class(se, "SummarizedExperiment")
    meta <- jsonlite::fromJSON(file.path(tmp, "_bioconductor.json"), simplifyVector=FALSE)
    expect_identical(meta$bioconductor_version, as.character(BiocManager::version()))

    # Validation fails as expected.
    tmp <- tempfile()
    meta$title <- 1234
    expect_error(saveReference(x, labels, tmp, meta), "title")
})

test_that("saveReference works with ReloadedArray objects", {
    meta <- list(
        title="My dataset",
        description="This is my dataset",
        taxonomy_id="10090",
        genome="GRCh38",
        sources=list(list(provider="GEO", id="GSE12345")),
        maintainer_name="Shizuka Mogami",
        maintainer_email="mogami.shizuka@765pro.com"
    )

    # Saving something to link to.
    tmp <- tempfile()
    saveReference(x, labels, tmp, meta)

    # Adding a ReloadedArray assay.
    x2 <- alabaster.matrix::ReloadedArray(path=file.path(tmp, "assays", "0"), seed=matrix(runif(1000), 100, 10))
    rownames(x2) <- rownames(x)

    # Checking that the link targets are created correctly.
    tmp2 <- tempfile()
    saveReference(x2, labels, tmp2, meta)
    expect_true(nchar(Sys.readlink(file.path(tmp2, "assays", "0", "array.h5"))) > 0L) # check that these are indeed symlinks.

    roundtrip <- alabaster.base::readObject(tmp2)
    expect_identical(as.matrix(assay(roundtrip)), x) # all assays are just symlinked to the first save!
})
