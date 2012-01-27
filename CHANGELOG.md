# 0.0.8
* make counts behave properly, along with some api changes required
  to make counts work properly

# 0.0.7
* changes filters method to filter_for, and filters must be defined
  in separate method calls, i.e.:

    filter_for :status
    filter_for :state

  as opposed to:

    filters :status, :state

  this is necessary to allow us to pass options on a per filter
  basis

* collection option for filter_for method.  Passing an option called
  collection to the filter_for method with the value of the option
  being an array of hashes, models, etc., will override the default list
  of filter options if formatted correctly

# 0.0.6
* cache counts query per filter, per request
* cache option_objects query per filter, per request
* fix a bug where counts weren't updating on filter selection change in
  some cases
* refactor
