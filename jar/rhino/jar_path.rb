
module Rhino
  JAR_VERSION = "1.7.4"
  version_parts = JAR_VERSION.split(".")
  current_dir = File.dirname(__FILE__)
  jar_file = "rhino-#{version_parts[0]}.#{version_parts[1]}R#{version_parts[2]}.jar"
  JAR_PATH = File.expand_path("../#{jar_file}", current_dir)
end
