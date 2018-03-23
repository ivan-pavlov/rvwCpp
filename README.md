# rvwCpp
Test R interface to [Vowpal Wabbit](https://github.com/JohnLangford/vowpal_wabbit/wiki) for GSoC 2018.

Written using `Rcpp` and `libvw`.

### Requirements

This package requires `vw` libraries.
You can get them [here](https://github.com/JohnLangford/vowpal_wabbit/wiki/Download).

`vw` libraries should be installed in default directories:
`/usr/local/include/`, `/usr/local/lib`

Also requires `perf` [program](http://osmot.cs.cornell.edu/kddcup/software.html) to compute AUC score.

### Installation

```R
library(devtools)
install_github("ivan-pavlov/rvwCpp")
```
### Examples

Demonstration file is in `demo/rvwCpp_example.R`

Function `vwCpp` uses files in `.vw` [format](https://github.com/JohnLangford/vowpal_wabbit/wiki/Input-format).

```R
aucCpp <- vwCpp(training_data = "diamond_train.vw", validation_data = "diamond_val.vw", 
			validation_labels = "valid_labels.txt", out_probs = "predsCpp.vw", model = "mdlCpp.vw",
			loss = "logistic", link_function = "logistic", do_evaluation = TRUE,
			b = 25, learning_rate = 0.5, passes = 1)
```

### Usage

Parameters | Description
--- | ---
`training_data` | File in vw format with data to train model
`validation_data` | File in vw format with data to compute predictions
`validation_labels` | plain text file with true labels from `validation_data`. One label on each line
`out_probs` | File where to write final predictions
`model` | File where to write final model
`loss` | loss function, default is "logistic"
`link_function` | link function, default is "logistic"
`b` | Number of bits in the feature table, default is 25
`learning_rate` | Initial learning_rate, default is 0.5
`passes` | Number of training passes, default is 1
`do_evaluation` | If TRUE, AUC score will be computed using `perf`