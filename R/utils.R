#' @importFrom ExperimentHub ExperimentHub
#' @importFrom SummarizedExperiment SummarizedExperiment
#' @importFrom SummarizedExperiment rowData
#' @importFrom S4Vectors DataFrame
.create_se <- function(dataset, version, hub = ExperimentHub(), assays="logcounts",
    rm.NA = c("rows","cols","both","none"), has.rowdata=FALSE, has.coldata=TRUE) 
{
    rm.NA <- match.arg(rm.NA)
    host <- file.path("celldex", dataset)

    ## extract normalized values --------
    all.assays <- list()
    for (a in assays) {
        ver <- .fetch_version(version, a)
        nrmcnts <- hub[hub$rdatapath==file.path(host, ver, paste0(a, ".rds"))][[1]]
        all.assays[[a]] <- .rm_NAs(nrmcnts, rm.NA)
    }
    
    ## get metadata ----------------------
    args <- list()
    if (has.coldata) {
        ver <- .fetch_version(version, "coldata")
        args$colData <- hub[hub$rdatapath==file.path(host, ver, "coldata.rds")][[1]]
    }
    if (has.rowdata) {
        ver <- .fetch_version(version, "rowdata")
        args$rowData <- hub[hub$rdatapath==file.path(host, ver, "rowdata.rds")][[1]]
    }
    
    ## make the final SE object ----------
    do.call(SummarizedExperiment, c(list(assays=all.assays), args))
}

.fetch_version <- function(version, field) {
    opt <- version[field]
    if (is.na(opt)) {
        version[1]
    } else {
        opt
    }
}

#' @importFrom DelayedMatrixStats rowAnyNAs colAnyNAs
#' @importFrom DelayedArray DelayedArray
.rm_NAs <- function(mat, rm.NA = "rows"){
    # Identify them first before removal, to ensure that 
    # the same rows are columns are removed with 'both'.
    if(rm.NA == "rows" || rm.NA == "both"){
        keep_rows <- !rowAnyNAs(DelayedArray(mat))
    } else {
        keep_rows <- !logical(nrow(mat))
    }

    if (rm.NA=="cols" || rm.NA == "both") {
        keep_cols <- !colAnyNAs(DelayedArray(mat))
    } else {
        keep_cols <- !logical(ncol(mat))
    }

    # Avoid making unnecessary copies if possible.
    if (!all(keep_rows)) {
        mat <- mat[keep_rows,,drop=FALSE]
    }
    if (!all(keep_cols)) {
        mat <- mat[,keep_cols,drop=FALSE]
    }
    mat
}

#' @importFrom AnnotationHub AnnotationHub
#' @importFrom AnnotationDbi mapIds
.convert_to_ensembl <- function(se, species, ensembl) 
# Copied verbatim from scRNAseq... well, whatever.
{
    if (ensembl) {
        if (species=="Mm") {
            tag <- "AH73905"
        } else if (species=="Hs") {
            tag <- "AH73881"
        }

        edb <- AnnotationHub()[[tag]]
        ensid <- mapIds(edb, keys=rownames(se), keytype="SYMBOL", column="GENEID")

        keep <- !is.na(ensid) & !duplicated(ensid)
        if (!all(keep)) {
            se <- se[keep,]
        }
        rownames(se) <- ensid[keep]
    }

    se
}

#' @importFrom utils read.delim
.add_ontology <- function(se, fname, mode) {
    if (mode!="none") {
        path <- system.file("mapping", paste0(fname, ".tsv"), package="celldex", mustWork=TRUE)
        src <- read.delim(path, header=FALSE, stringsAsFactors=FALSE)

        m <- match(se$label.fine, src[,1])
        stopifnot(all(!is.na(m))) # sanity check

        matched <- src[m, 2]
        matched[matched==""] <- NA_character_
        se$label.ont <- matched

        if (mode=="nonna") {
            se <- se[,!is.na(se$label.ont)]
        }
    }

    se
}
