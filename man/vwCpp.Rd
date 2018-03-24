\name{vwCpp}
\alias{vwCpp}
\title{
Vowpal Wabbit models in R
}
\description{
Basic function that can train Vowpal Wabbit models and then use them to compute predictions. Right now only supports binary classification. Uses external perf program to compute validation metrics.
}
\usage{
vwCpp(training_data, validation_data, validation_labels, out_probs, model, loss = "logistic", link_function = "logistic", b = 25L, learning_rate = 0.5, passes = 1L, do_evaluation = TRUE)
}
\arguments{
  \item{training_data}{
File in vw format with data to train model
}
  \item{validation_data}{
File in vw format with data to compute predictions
}
  \item{validation_labels}{
plain text file with true labels from validation_data. One label on each line
}
  \item{out_probs}{
File where to save final predictions
}
  \item{model}{
File where to save final model
}
  \item{loss}{
loss function, default is "logistic"
}
  \item{link_function}{
link function, default is "logistic"
}
  \item{b}{
Number of bits in the feature table, default is 25
}
  \item{learning_rate}{
Initial learning_rate, default is 0.5
}
  \item{passes}{
Number of training passes, default is 1
}
  \item{do_evaluation}{
If TRUE, AUC score will be computed using perf
}
}
\value{
List that contains:
\item{auc }{auc score computed using perf}
\item{data }{data.frame with predictions computed for validation_data}
\item{fitcmd }{vw parameters that were used to train model}
\item{predictcmd }{vw parameters that were used to compute predictions}
}
\examples{
# Use rvw library to prepare data
library(rvw)

# Prepare train and validation data in vw format
data("diamonds", package = "ggplot2")
dt <- diamonds
dt$y <- with(dt, ifelse(y < 5.71, 1, -1))
ind_train <- sample(1:nrow(dt), 40000)
dt_train <- dt[ind_train,]
dt_val <- dt[-ind_train,]
cwd <- getwd()
setwd(tempdir())
dt2vw(data <- dt_train, fileName = "diamond_train.vw", target = "y")
dt2vw(data <- dt_val, fileName = "diamond_val.vw", target = "y")
write.table(x <- dt_val$y, file = "valid_labels.txt",
            row.names = FALSE, col.names = FALSE)

# Call function
auc <- vwCpp(training_data = "diamond_train.vw", validation_data = "diamond_val.vw",
    validation_labels = "valid_labels.txt",
    loss = "logistic", link_function = "logistic", 
    b = 25L, learning_rate = 0.5, passes = 1L, do_evaluation = TRUE) 
setwd(cwd)
}

