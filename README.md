# Index of reference cell type datasets for Bioconductor

|Environment|Status|
|---|---|
|[BioC-release](https://bioconductor.org/packages/release/data/experiment/html/celldex.html)|[![Release OK](https://bioconductor.org/shields/build/release/data-experiment/celldex.svg)](http://bioconductor.org/checkResults/release/data-experiment-LATEST/celldex/)|
|[BioC-devel](https://bioconductor.org/packages/devel/data/experiment/html/celldex.html)|[![Devel OK](https://bioconductor.org/shields/build/devel/data-experiment/celldex.svg)](http://bioconductor.org/checkResults/devel/data-experiment-LATEST/celldex/)|

This package provides reference datasets with annotated cell types for convenient use by other Bioconductor packages and workflows.
References were originally sourced from the [first edition of the **SingleR** package](https://github.com/dviraran/SingleR) but more datasets have been added since then.
Each dataset is loaded as a [`SummarizedExperiment`](https://bioconductor.org/packages/SummarizedExperiment) that is immediately ready for further analysis.
To get started, install the package and its dependencies from Bioconductor:

```r
# install.packages("BiocManager")
BiocManager::install("celldex")
```

Find datasets of interest:

```r
surveyReferences()
searchReferences(defineTextQuery("immune"))
```

Fetch a dataset as a `SummarizedExperiment`:

```r
fetchReference("immgen", version="2024-02-26")
fetchReference("hpca", "2024-02-26")
```

And add your own datasets to enable re-use by the wider Bioconductor community.

Check out the [user's guide](https://bioconductor.org/packages/release/data/experiment/vignettes/celldex/inst/doc/userguide.html) for more details.

## Maintainer notes

If someone wants to contribute a new dataset, they should follow the instructions in the user's guide.
This requires a bit of effort on our (i.e., the package maintainers') part to process a new submission.

Once a prospective uploader has prepared their `SummarizedExperiment` and its associated metadata,
they can be given temporary upload permissions for, e.g., a week, by calling:

```r
gypsum::setPermissions("celldex", uploaders=list(
    list(
        id="GITHUB_LOGIN", 
        asset="NAME_OF_THE_DATASET_THEY_WANT_TO_UPLOAD",
        version="VERSION_THEY_WANT_TO_UPLOAD",
        until=Sys.time() + 7 * 24 * 3600
    )
)
```

Once the upload is complete, we pull down the dataset for review.

```r
cache <- tempfile()
dest <- gypsum::saveVersion(
    "celldex", 
    asset="NAME_OF_THE_DATASET_THEY_WANT_TO_UPLOAD",
    version="VERSION_THEY_WANT_TO_UPLOAD",
    cache=cache
)

# Check that the saved object is valid. You might need to do this for each
# subdirectory if they saved multiple objects in a single dataset.
alabaster.base::validateObject(dest)

# You can also just try loading it for inspection in the R session.
alabaster.base::readObject(dest)

# Check that the metadata is valid.
lines <- readLines(file.path(dest, "_bioconductor.json"))
gypsum::validateMetadata(paste(lines, collapse="\n"))
```

If everything looks okay, we can approve the probational dataset.
Otherwise we reject it.

```r
# Okay.
gypsum::approveProbation(
    "celldex", 
    asset="NAME_OF_THE_DATASET_THEY_WANT_TO_UPLOAD",
    version="VERSION_THEY_WANT_TO_UPLOAD"
)

# Not okay.
gypsum::rejectProbation(
    "celldex", 
    asset="NAME_OF_THE_DATASET_THEY_WANT_TO_UPLOAD",
    version="VERSION_THEY_WANT_TO_UPLOAD"
)
```
