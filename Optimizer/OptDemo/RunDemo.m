addpath('E:\work\MyClass\Optimizer\OptDemo');
load Input
OptSetUp=Optimizer_Cplex_Sus(Input);
OptSetUp.Optimize();
OptPort=OptSetUp.OptPort;