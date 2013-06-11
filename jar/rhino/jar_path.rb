
module Rhino
  specs = Gem.loaded_specs["therubyrhino_jar"]
  version = specs.version.to_s.split(".")
  jar_file = "rhino-#{version[0]}.#{version[1]}R#{version[2]}.jar"
  JAR_PATH = File.expand_path("../#{jar_file}", File.dirname(__FILE__))
end
