## Math6120 - Nonlinear Optimisation
## Coursework 2 - AMPL Model
## Emma Tarmey, 2940 4045


## This file specifies the mathematical model used to solve our problem


## sets

# PROPERTIES acts as a structure for organising the three variables
# associated with each of our 22 substances
# 1 = quantity / amount (kton)
# 2 = sulphur content (%)
# 3 = viscosity (V50%)
set PROPERTIES := {'quantity', 'sulphur', 'viscosity'};
set QUANTITY   := {'quantity'};


## parameters
param lsfo_base_price;
param hsfo_base_price;
param lsfo_sulphur_upper_bound;
param hsfo_sulphur_upper_bound;


## variables

# starting product variables
var hs1 {p in QUANTITY} >= 0; # high-sulphur crude oil
var hs2 {p in QUANTITY} >= 0; # high-sulphur crude oil
var ls1 {p in QUANTITY} >= 0; # low-sulphur crude oil
var ls2 {p in QUANTITY} >= 0; # low-sulphur crude oil

# intermediate product variables
var hs1_sr  {p in PROPERTIES} >= 0; # short residue
var hs1_cr  {p in PROPERTIES} >= 0; # cracked residue
var hs1_hgo {p in PROPERTIES} >= 0; # heavy gas oil
var hs1_vgo {p in PROPERTIES} >= 0; # visbroken gas oil

var hs2_sr  {p in PROPERTIES} >= 0;
var hs2_cr  {p in PROPERTIES} >= 0;
var hs2_hgo {p in PROPERTIES} >= 0;
var hs2_vgo {p in PROPERTIES} >= 0;

var ls1_sr  {p in PROPERTIES} >= 0;
var ls1_cr  {p in PROPERTIES} >= 0;
var ls1_hgo {p in PROPERTIES} >= 0;
var ls1_vgo {p in PROPERTIES} >= 0;

var ls2_sr  {p in PROPERTIES} >= 0;
var ls2_cr  {p in PROPERTIES} >= 0;
var ls2_hgo {p in PROPERTIES} >= 0;
var ls2_vgo {p in PROPERTIES} >= 0;

# tank product variables
var tank_one {p in PROPERTIES} >= 0;
var tank_two {p in PROPERTIES} >= 0;

# final product variables
var hsfo {p in PROPERTIES} >= 0; # high-sulphur fuel oil
var lsfo {p in PROPERTIES} >= 0; # low-sulphur fuel oil

# linear interpolation variable (used for blending)
var t >= 0;

# price calculation variables
var lsfo_actual_price =
    lsfo_base_price * (2 - (lsfo['sulphur'] / lsfo_sulphur_upper_bound));
var hsfo_actual_price =
    hsfo_base_price * (2 - (hsfo['sulphur'] / hsfo_sulphur_upper_bound));

# blending variables
var high_sulphur_intermediate_weighted_sulphur = (
	(hs1_sr['quantity']*hs1_sr['sulphur'])   +
	(hs1_cr['quantity']*hs1_cr['sulphur'])   +
	(hs1_hgo['quantity']*hs1_hgo['sulphur']) +
	(hs1_vgo['quantity']*hs1_vgo['sulphur']) +
	(hs2_sr['quantity']*hs2_sr['sulphur'])   +
	(hs2_cr['quantity']*hs2_cr['sulphur'])   +
	(hs2_hgo['quantity']*hs2_hgo['sulphur']) +
	(hs2_vgo['quantity']*hs2_vgo['sulphur']));

var low_sulphur_intermediate_weighted_sulphur = (
	(ls1_sr['quantity']*ls1_sr['sulphur'])   +
	(ls1_cr['quantity']*ls1_cr['sulphur'])   +
	(ls1_hgo['quantity']*ls1_hgo['sulphur']) +
	(ls1_vgo['quantity']*ls1_vgo['sulphur']) +
	(ls2_sr['quantity']*ls2_sr['sulphur'])   +
	(ls2_cr['quantity']*ls2_cr['sulphur'])   +
	(ls2_hgo['quantity']*ls2_hgo['sulphur']) +
	(ls2_vgo['quantity']*ls2_vgo['sulphur']));

var high_sulphur_intermediate_weighted_viscosity = (
	(hs1_sr['quantity']*hs1_sr['viscosity'])   +
	(hs1_cr['quantity']*hs1_cr['viscosity'])   +
	(hs1_hgo['quantity']*hs1_hgo['viscosity']) +
	(hs1_vgo['quantity']*hs1_vgo['viscosity']) +
	(hs2_sr['quantity']*hs2_sr['viscosity'])   +
	(hs2_cr['quantity']*hs2_cr['viscosity'])   +
	(hs2_hgo['quantity']*hs2_hgo['viscosity']) +
	(hs2_vgo['quantity']*hs2_vgo['viscosity']));

var low_sulphur_intermediate_weighted_viscosity = (
	(ls1_sr['quantity']*ls1_sr['viscosity'])   +
	(ls1_cr['quantity']*ls1_cr['viscosity'])   +
	(ls1_hgo['quantity']*ls1_hgo['viscosity']) +
	(ls1_vgo['quantity']*ls1_vgo['viscosity']) +
	(ls2_sr['quantity']*ls2_sr['viscosity'])   +
	(ls2_cr['quantity']*ls2_cr['viscosity'])   +
	(ls2_hgo['quantity']*ls2_hgo['viscosity']) +
	(ls2_vgo['quantity']*ls2_vgo['viscosity']));


var high_sulphur_total_quantity = (hs1_sr['quantity']  + hs1_cr['quantity'] +
                                   hs1_hgo['quantity'] + hs1_vgo['quantity'] +
                                   hs2_sr['quantity']  + hs2_cr['quantity'] +
                                   hs2_hgo['quantity'] + hs2_vgo['quantity']);

var low_sulphur_total_quantity  = (ls1_sr['quantity']  + ls1_cr['quantity'] +
                                   ls1_hgo['quantity'] + ls1_vgo['quantity'] +
                                   ls2_sr['quantity']  + ls2_cr['quantity'] +
                                   ls2_hgo['quantity'] + ls2_vgo['quantity']);


## objective function
maximize total_sales_volume: ( (lsfo['quantity'] * lsfo_actual_price) +
                               (hsfo['quantity'] * hsfo_actual_price) ) ;


## constraints

# linear interpolation constraint
subject to linear_interpolation:
	t <= 1;

# this constraint will simulate the removal of all pool tanks from production
# to include this constraint, un-comment the below 2 lines of code
#subject to remove_tanks:
#	t = 1;


## The production process we model takes 3 stages: distillation, pooling and blending
## The following 3 sets of constraints determine how each of these stages occur


# STAGE 1 - distillation constraints
subject to hs1_distillation:
	hs1['quantity'] >= hs1_sr['quantity']  + hs1_cr['quantity'] +
	                   hs1_hgo['quantity'] + hs1_vgo['quantity'];
subject to hs2_distillation:
	hs2['quantity'] >= hs2_sr['quantity']  + hs2_cr['quantity'] +
	                   hs2_hgo['quantity'] + hs2_vgo['quantity'];
subject to ls1_distillation:
	ls1['quantity'] >= ls1_sr['quantity']  + ls1_cr['quantity'] +
	                   ls1_hgo['quantity'] + ls1_vgo['quantity'];
subject to ls2_distillation:
	ls2['quantity'] >= ls2_sr['quantity']  + ls2_cr['quantity'] +
	                   ls2_hgo['quantity'] + ls2_vgo['quantity'];


# STAGE 2 - pooling constraints

# quantity of each tank's pool
subject to pooling_tank_one_quantity:
	tank_one['quantity'] = (hs1_sr['quantity']  + hs1_cr['quantity'] +
	                        hs1_hgo['quantity'] + hs1_vgo['quantity'] +
	                        hs2_sr['quantity']  + hs2_cr['quantity'] +
	                        hs2_hgo['quantity'] + hs2_vgo['quantity']);

subject to pooling_tank_two_quantity:
	tank_two['quantity'] = (ls1_sr['quantity']  + ls1_cr['quantity'] +
	                        ls1_hgo['quantity'] + ls1_vgo['quantity'] +
	                        ls2_sr['quantity']  + ls2_cr['quantity'] +
	                        ls2_hgo['quantity'] + ls2_vgo['quantity']);

# sulphur content of each tank's pool
subject to pooling_tank_one_sulphur:
	tank_one['sulphur'] =
	(high_sulphur_intermediate_weighted_sulphur / high_sulphur_total_quantity);
subject to pooling_tank_two_sulphur:
	tank_two['sulphur'] =
	(low_sulphur_intermediate_weighted_sulphur  / low_sulphur_total_quantity);

# viscosity of each tank's pool
subject to pooling_tank_one_viscosity:
	tank_one['viscosity'] =
	(high_sulphur_intermediate_weighted_viscosity / high_sulphur_total_quantity);
subject to pooling_tank_two_viscosity:
	tank_two['viscosity'] =
	(low_sulphur_intermediate_weighted_viscosity  / low_sulphur_total_quantity);

# max quantity of each tank
subject to tank_one_max_capacity:
	tank_one['quantity'] <= 15;
subject to tank_two_max_capacity:
	tank_two['quantity'] <= 15;


# STAGE 3 - blending constraints

# quantity of final products
subject to blending_hsfo_quantity:
	hsfo['quantity'] =
	((t * tank_one['quantity']) + ((1 - t) * tank_two['quantity']));
subject to blending_lsfo_quantity:
	lsfo['quantity'] =
	((t * tank_two['quantity']) + ((1 - t) * tank_one['quantity']));

# sulphur content of final products
subject to blending_hsfo_sulphur:
	hsfo['sulphur'] =
	((t * tank_one['sulphur']) + ((1 - t) * tank_two['sulphur']));
subject to blending_lsfo_sulphur:
	lsfo['sulphur'] =
	((t * tank_two['sulphur']) + ((1 - t) * tank_one['sulphur']));

# viscosity of final products
subject to blending_hsfo_viscosity:
	hsfo['viscosity'] =
	((t * tank_one['viscosity']) + ((1 - t) * tank_two['viscosity']));
subject to blending_lsfo_viscosity:
	lsfo['viscosity'] =
	((t * tank_two['viscosity']) + ((1 - t) * tank_one['viscosity']));


# The following constraints are all bounds on our 72 variables
# We organise the following constraints by production stage order


# intermediate product constraints

# quantity of high sulphur 1 intermediates
subject to hs1_sr_quantity_min:
	hs1_sr['quantity']  >= 1;
subject to hs1_sr_quantity_max:
	hs1_sr['quantity']  <= 3;
subject to hs1_cr_quantity_min:
	hs1_cr['quantity']  >= 0;
subject to hs1_cr_quantity_max:
	hs1_cr['quantity']  <= 3;
subject to hs1_hgo_quantity_min:
	hs1_hgo['quantity'] >= 0;
subject to hs1_hgo_quantity_max:
	hs1_hgo['quantity'] <= 3;
subject to hs1_vgo_quantity_min:
	hs1_vgo['quantity'] >= 0;
subject to hs1_vgo_quantity_max:
	hs1_vgo['quantity'] <= 3;

# quantity of high sulphur 2 intermediates
subject to hs2_sr_quantity_min:
	hs2_sr['quantity']  >= 1;
subject to hs2_sr_quantity_max:
	hs2_sr['quantity']  <= 3;
subject to hs2_cr_quantity_min:
	hs2_cr['quantity']  >= 0;
subject to hs2_cr_quantity_max:
	hs2_cr['quantity']  <= 3;
subject to hs2_hgo_quantity_min:
	hs2_hgo['quantity'] >= 0;
subject to hs2_hgo_quantity_max:
	hs2_hgo['quantity'] <= 3;
subject to hs2_vgo_quantity_min:
	hs2_vgo['quantity'] >= 0;
subject to hs2_vgo_quantity_max:
	hs2_vgo['quantity'] <= 3;

# quantity of low sulphur 1 intermediates
subject to ls1_sr_quantity_min:
	ls1_sr['quantity']  >= 1;
subject to ls1_sr_quantity_max:
	ls1_sr['quantity']  <= 3;
subject to ls1_cr_quantity_min:
	ls1_cr['quantity']  >= 0;
subject to ls1_cr_quantity_max:
	ls1_cr['quantity']  <= 3;
subject to ls1_hgo_quantity_min:
	ls1_hgo['quantity'] >= 0;
subject to ls1_hgo_quantity_max:
	ls1_hgo['quantity'] <= 3;
subject to ls1_vgo_quantity_min:
	ls1_vgo['quantity'] >= 0;
subject to ls1_vgo_quantity_max:
	ls1_vgo['quantity'] <= 3;

# quantity of low sulphur 2 intermediates
subject to ls2_sr_quantity_min:
	ls2_sr['quantity']  >= 1;
subject to ls2_sr_quantity_max:
	ls2_sr['quantity']  <= 3;
subject to ls2_cr_quantity_min:
	ls2_cr['quantity']  >= 0;
subject to ls2_cr_quantity_max:
	ls2_cr['quantity']  <= 3;
subject to ls2_hgo_quantity_min:
	ls2_hgo['quantity'] >= 0;
subject to ls2_hgo_quantity_max:
	ls2_hgo['quantity'] <= 3;
subject to ls2_vgo_quantity_min:
	ls2_vgo['quantity'] >= 0;
subject to ls2_vgo_quantity_max:
	ls2_vgo['quantity'] <= 3;

# sulphur content of the HS1 intermediates
subject to hs1_sr_sulphur:
	hs1_sr['sulphur']  = 5.84;
subject to hs1_cr_sulphur:
	hs1_cr['sulphur']  = 5.40;
subject to hs1_hgo_sulphur:
	hs1_hgo['sulphur'] = 0.24;
subject to hs1_vgo_sulphur:
	hs1_vgo['sulphur'] = 2.01;

# sulphur content of the HS2 intermediates
subject to hs2_sr_sulphur:
	hs2_sr['sulphur']  = 5.85;
subject to hs2_cr_sulphur:
	hs2_cr['sulphur']  = 5.38;
subject to hs2_hgo_sulphur:
	hs2_hgo['sulphur'] = 0.26;
subject to hs2_vgo_sulphur:
	hs2_vgo['sulphur'] = 2.04;

# sulphur content of the LS1 intermediates
subject to ls1_sr_sulphur:
	ls1_sr['sulphur']  = 0.64;
subject to ls1_cr_sulphur:
	ls1_cr['sulphur']  = 0.57;
subject to ls1_hgo_sulphur:
	ls1_hgo['sulphur'] = 0.02;
subject to ls1_vgo_sulphur:
	ls1_vgo['sulphur'] = 0.14;

# sulphur content of the LS2 intermediates
subject to ls2_sr_sulphur:
	ls2_sr['sulphur']  = 0.93;
subject to ls2_cr_sulphur:
	ls2_cr['sulphur']  = 0.85;
subject to ls2_hgo_sulphur:
	ls2_hgo['sulphur'] = 0.03;
subject to ls2_vgo_sulphur:
	ls2_vgo['sulphur'] = 0.26;

# viscosity of the HS1 intermediates
subject to hs1_sr_viscosity:
	hs1_sr['viscosity']  = 43.7;
subject to hs1_cr_viscosity:
	hs1_cr['viscosity']  = 36.8;
subject to hs1_hgo_viscosity:
	hs1_hgo['viscosity'] = 12.8;
subject to hs1_vgo_viscosity:
	hs1_vgo['viscosity'] = 15.4;

# viscosity of the HS2 intermediates
subject to hs2_sr_viscosity:
	hs2_sr['viscosity']  = 47.3;
subject to hs2_cr_viscosity:
	hs2_cr['viscosity']  = 39.2;
subject to hs2_hgo_viscosity:
	hs2_hgo['viscosity'] = 13.1;
subject to hs2_vgo_viscosity:
	hs2_vgo['viscosity'] = 15.9;

# viscosity of the LS1 intermediates
subject to ls1_sr_viscosity:
	ls1_sr['viscosity']  = 39.9;
subject to ls1_cr_viscosity:
	ls1_cr['viscosity']  = 38.2;
subject to ls1_hgo_viscosity:
	ls1_hgo['viscosity'] = 13.5;
subject to ls1_vgo_viscosity:
	ls1_vgo['viscosity'] = 16.3;

# viscosity of the LS2 intermediates
subject to ls2_sr_viscosity:
	ls2_sr['viscosity']  = 38.1;
subject to ls2_cr_viscosity:
	ls2_cr['viscosity']  = 34.1;
subject to ls2_hgo_viscosity:
	ls2_hgo['viscosity'] = 13.2;
subject to ls2_vgo_viscosity:
	ls2_vgo['viscosity'] = 15.5;



# final product requirements

# quantity of final products
subject to lsfo_quantity_min:
	lsfo['quantity'] >= 10;
subject to lsfo_quantity_max:
	lsfo['quantity'] <= 11;
subject to hsfo_quantity_min:
	hsfo['quantity'] >= 11;
subject to hsfo_quantity_max:
	hsfo['quantity'] <= 17;

# sulphur content of final products
subject to lsfo_sulphur_min:
	lsfo['sulphur'] >= 0.0;
subject to lsfo_sulphur_max:
	lsfo['sulphur'] <= lsfo_sulphur_upper_bound;
subject to hsfo_sulphur_min:
	hsfo['sulphur'] >= 0.0;
subject to hsfo_sulphur_max:
	hsfo['sulphur'] <= hsfo_sulphur_upper_bound;

# viscosity of final products
subject to lsfo_viscosity_min:
	lsfo['viscosity'] >= 30.0;
subject to lsfo_viscosity_max:
	lsfo['viscosity'] <= 34.0;
subject to hsfo_viscosity_min:
	hsfo['viscosity'] >= 32.0;
subject to hsfo_viscosity_max:
	hsfo['viscosity'] <= 40.0;




