#include <Rcpp.h>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <fstream>
#include "vowpalwabbit/parser.h"
#include "vowpalwabbit/vw.h"
using namespace Rcpp;


//  Get stdout from external program
int parse_output(std::string cmd, std::string& res) {
    char buf[128];
    FILE *fp;

    if ((fp = popen(cmd.c_str(), "r")) == NULL) {
        printf("Error opening pipe!\n");
        return -1;
    }

    while (fgets(buf, 128, fp) != NULL) {
        *std::remove(buf, buf+strlen(buf), '\n') = '\0';
        res += buf;
    }

    if(pclose(fp))  {
        printf("Command not found or exited with error status\n");
        return -1;
    }

    return 0;
}

// Get number of examples used in model
int get_num_example(vw& all) {
    return all.sd->example_number / all.current_pass;
  }


// [[Rcpp::export]]
List vwCpp(std::string training_data, std::string validation_data, 
           std::string validation_labels,std::string out_probs,std::string model,
           std::string loss = "logistic",std::string link_function = "logistic", 
           int b = 25, float learning_rate = 0.5, int passes = 1, bool do_evaluation = true) {

  // Constuct initializing string from args
  std::string train_init_str = "-d " + training_data + " -f " + model + " --loss_function " 
  + loss + " -b " + std::to_string(b) + " --learning_rate " + std::to_string(learning_rate) 
  + " --passes " + std::to_string(passes);

  if (passes > 1)
  {
    // Add caching 
    // That is required if num of passes > 1 
    train_init_str += " -c";
  }

  std::cout << "Using parameters:" << std::endl << train_init_str << std::endl;
  vw* train_model = VW::initialize(train_init_str);
  
  // Use standart file parser to get examples and train model
  VW::start_parser(*train_model);
  std::cerr << "average  since         example        example  current  current  current" << std::endl;
  std::cerr << "loss     last          counter         weight    label  predict features" << std::endl;
  LEARNER::generic_driver(*train_model);
  VW::end_parser(*train_model);
  VW::finish(*train_model);
  
  // Constuct initializing string for predicting model
  std::string predict_init_str = "-t -i " + model + " --link " + link_function + " -p " + out_probs + " -d " + validation_data;
  std::cout << "Using parameters:" << std::endl << predict_init_str << std::endl;
  vw* predict_model = VW::initialize(predict_init_str);

  // Use standart file parser to get validation examples and predict labels
  VW::start_parser(*predict_model);
  std::cerr << "average  since         example        example  current  current  current" << std::endl;
  std::cerr << "loss     last          counter         weight    label  predict features" << std::endl;
  LEARNER::generic_driver(*predict_model);
  VW::end_parser(*predict_model);
  int num_of_examples = get_num_example(*predict_model);
  VW::finish(*predict_model);

  // Compute auc using perf
  std::string auc = "";
  if (do_evaluation)
  {
    std::string path_to_perf;
    std::cout << "starting perf..." << std::endl;

    parse_output("which perf", path_to_perf);
    std::cout << "at: " << path_to_perf  << std::endl;
    std::string tmp = path_to_perf + " -ROC -files " + validation_labels + " " + out_probs + " | cut -c8-14";
    std::cout << tmp << std::endl;
    parse_output(path_to_perf + " -ROC -files " + validation_labels + " " + out_probs + " | cut -c8-14", auc);
    std::cout << "auc: " << auc << std::endl;
  }

  // Constuct DataFrame similar to result from vw.R function
  NumericVector data_vec(num_of_examples);
  std::ifstream probs_file (out_probs);
  std::string line;
  for (int i = 0; i < num_of_examples; ++i)
  {
    getline(probs_file, line);
    data_vec[i] = std::stof(line);
  }
  DataFrame data_df = DataFrame::create(Rcpp::Named("predicted")=data_vec);

  // Return List similar to result from vw.R function
  return List::create(Named("auc") = auc,
                          Named("data") = data_df,
                          Named("fitcmd") = "./vw " + train_init_str,
                          Named("predictcmd") = "./vw " + predict_init_str);

 }