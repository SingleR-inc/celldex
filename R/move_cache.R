.move_cache <- function(pkg, envvar) { 
    if (!is.na(Sys.getenv(envvar, NA))) {
        return(NULL)
    }

    olddir <- path.expand(rappdirs::user_cache_dir(appname=pkg))
    if (!file.exists(olddir)) {
        return(NULL)
    }

    newdir <- tools::R_user_dir(pkg, which="cache")
    if (file.exists(newdir)) {
        # Shouldn't happen that we have both new and old caches, 
        # but whatever, you can deal with it.
        return(NULL)
    }

    dir.create(path=newdir, recursive=TRUE)
    destroyme <- newdir
    on.exit(unlink(destroyme, recursive=TRUE, force=TRUE))

    files <- list.files(olddir, full.names =TRUE)
    for (f in files) {
        newname <- file.path(newdir, basename(f))
        if (!file.exists(newname)) { # weak protection against concurrent evaluation.
            if (!file.link(f, newname) && !file.copy(f, newname)) {
                return(NULL)
            }
        }
    }

    destroyme <- olddir
    NULL
}
