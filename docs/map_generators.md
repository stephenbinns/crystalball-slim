# Map generators

## Execution Map Generator

There are different map generator strategies that can (and should) be used together for better predictions. Each one has its own benefits and drawbacks, so they should be configured to best fit your needs.

### Custom map file name

You can customize resulting map filename with `map_storage_path` value. E.g.
```ruby
Crystalball::MapGenerator.start! do |config|
  #...
  config.map_storage_path = "execution_map_#{ENV['TEST_ENV_NUMBER'].to_i}.yml"
end
```

### CoverageStrategy

Uses coverage information to detect which files are covered by the given spec (i.e. the files that, if changed, may potentially break the spec);
To customize the way the execution detection works, pass an object that responds to #detect and returns the paths to the strategy initialization:

```ruby
Crystalball::MapGenerator.start! do |config|
  #...
  config.register Crystalball::MapGenerator::CoverageStrategy.new(my_detector)
end
```

By default, the execution detector is a `Crystalball::MapGenerator::CoverageStrategy::ExecutionDetector`, which filters out the paths outside of the project root and converts absolute paths to relative.

### AllocatedObjectsStrategy

Looks for the files in which the objects allocated during the spec execution are defined. It is considerably slower than `CoverageStrategy`.
To use this strategy, use the convenient method `.build` which takes two optional keyword arguments: `only`, used to define the classes or modules to have their descendants tracked (defaults to `[]`); and `root`, which is the path where the detection will take place (defaults to `Dir.pwd`).
Here's an example that tracks allocation of `ActiveRecord::Base` objects:

```ruby
Crystalball::MapGenerator.start! do |config|
  #...
  config.register Crystalball::MapGenerator::AllocatedObjectsStrategy.build(only: ['ActiveRecord::Base'])
end
```

That method is fine for most uses, but if you need to further customize the behavior of the strategy, you can directly instantiate the class.

```ruby
Crystalball::MapGenerator.start! do |config|
  #...
  config.register Crystalball::MapGenerator::AllocatedObjectsStrategy
    .new(execution_detector: my_detector, object_tracker: my_tracker)
end
```

The initialization takes two keyword arguments: `execution_detector` and `object_tracker`.
`execution_detector` must be an object that responds to `#detect` receiving a list of objects and returning the paths affected by said objects. `object_tracker` is something that responds to `#used_classes_during` which yields to the caller and returns the array of classes of objects allocated during the execution of the block.

### DescribedClassStrategy

This strategy will take each example that has a `described_class` (i.e. examples inside `describe` blocks of classes and not strings) and add the paths where the described class and its ancestors are defined to the example group map of the example;

To use it, add to your `Crystalball::MapGenerator.start!` block:

```ruby
Crystalball::MapGenerator.start! do |config|
  #...
  config.register Crystalball::MapGenerator::DescribedClassStrategy.new
end
```

As with `AllocatedObjectsStrategy`, you can pass a custom execution detector (an object that responds to `#detect` and returns the paths) to the initialization:

```ruby
Crystalball::MapGenerator.start! do |config|
  #...
  config.register Crystalball::MapGenerator::DescribedClassStrategy.new(my_detector)
end
```

### Custom strategies

You can create your own strategy and use it with the map generator. Any object that responds to `#call(example_group_map, example)` (where `example_group_map` is a `Crystalball::ExampleGroupMap` and `example` a `RSpec::Core::Example`) and augmenting its list of used files using `example_group_map.push(*paths_to_files)`.
Check out the [implementation](https://github.com/toptal/crystalball/tree/master/lib/crystalball/map_generator) of the default strategies for examples.

Keep in mind that all the strategies configured for the map generator will run for each example of your test suite, so it may slow down the generation process considerably.

### Debugging

By default MapGenerator generates compact map. In case you need plain and easily readable map add to your config:
```ruby
Crystalball::MapGenerator.start! do |config|
  #...
  config.compact_map = false
end
``` 
