# Production-Planning-Nonlinear-Optimization-AMPL
A nonlinear optimization project concerned with maximising revenues for a production plan, subject to nonlinear constraints, for a hypothetical oil refinery seeking to optimise the fuel oils.

The production is carried out across 3 production stages:
 - distillation
 - pooling
 - blending

These stages separate 4 sets of products:
 - crude oils
 - intermediate products
 - tank products
 - final products

We additionally consider 3 aspects of any given product at any given stage:
 - quantity
 - sulphur content
 - viscosity

We may make decisions about the above at any point, and seek to maximise revenues subject to variable unit price dependent on sulphur contents.
We investigate optimal solutions to our problem in AMPL and then consider more subtle questions about our solutions in the corresponding report.
