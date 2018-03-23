# Simple demo to demonstrate usage of vwCpp function and compare it with rvw
# This demo uses data from vw_example_2.R

library(rvw)
library(rvwCpp)
library(microbenchmark)

set.seed(123)

## data
data("diamonds", package = "ggplot2")
dt <- diamonds
dt$y <- with(dt, ifelse(y < 5.71, 1, -1))

## separate train and validation data
ind_train <- sample(1:nrow(dt), 40000)
dt_train <- dt[ind_train,]
dt_val <- dt[-ind_train,]

## to not randomly leaves files behind, change to
## temporary directory of the current R session
cwd <- getwd()
setwd(tempdir())

## first method: creating the vw data files before training
dt2vw(data <- dt_train, fileName = "diamond_train.vw", target = "y")
dt2vw(data <- dt_val, fileName = "diamond_val.vw", target = "y")

write.table(x <- dt_val$y, file = "valid_labels.txt",
            row.names = FALSE, col.names = FALSE)


aucR <- vw(training_data = "diamond_train.vw", validation_data = "diamond_val.vw", 
           validation_labels = "valid_labels.txt", out_probs = "predsR.vw", model = "mdlR.vw",
           loss = "logistic", link_function = "--link=logistic", 
           b = 25, learning_rate = 0.5, passes = 10, 
           use_cache = TRUE, keep_tempfiles = TRUE, do_evaluation = TRUE, 
           use_perf = TRUE, plot_roc = FALSE, verbose = TRUE)
# Produces similar to "vw.R" output structure with predicted data available
aucCpp <- vwCpp(training_data = "diamond_train.vw", validation_data = "diamond_val.vw", 
                validation_labels = "valid_labels.txt", out_probs = "predsCpp.vw", model = "mdlCpp.vw", 
                loss = "logistic", link_function = "logistic", do_evaluation = TRUE,
                b = 25, learning_rate = 0.5, passes = 10)

# Same results for both implementations
aucR$auc
aucCpp$auc

# Data is accessible here
head(aucCpp$data)

# microbenchmark to test running time

# microbenchmark(
#   vw(training_data = "diamond_train.vw", validation_data = "diamond_val.vw", 
#      validation_labels = "valid_labels.txt", out_probs = "predsR.vw", model = "mdlR.vw",
#      loss = "logistic", link_function = "--link=logistic", 
#      b = 25, learning_rate = 0.5, passes = 1, 
#      use_cache = FALSE, keep_tempfiles = FALSE, do_evaluation = FALSE, 
#      use_perf = TRUE, plot_roc = FALSE, verbose = TRUE),
#   vwCpp(training_data = "diamond_train.vw", validation_data = "diamond_val.vw", 
#         validation_labels = "valid_labels.txt", out_probs = "predsCpp.vw", model = "mdlCpp.vw",
#         loss = "logistic", link_function = "logistic", 
#         b = 25, learning_rate = 0.5, passes = 1, 
#         do_evaluation = FALSE)
# )

# This may take some time so here are computed results:
# min       lq        mean      median    uq        max        neval cld
# 808.5676  861.3690  911.3917  900.3781  946.0034  1233.632   100   b
# 808.6450  851.8337  890.2182  872.0186  915.7418  1200.618   100   a 

# The difference might not be dramatic, but that is just using a standart parser
# Complete implementation will use customized parser from libvw

# return back
setwd(cwd)