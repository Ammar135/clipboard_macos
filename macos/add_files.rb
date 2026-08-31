require 'xcodeproj'

project_path = 'macos/Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the main target
target = project.targets.find { |t| t.name == 'Runner' }

# Find the Runner group
runner_group = project.main_group.groups.find { |g| g.path == 'Runner' } || project.main_group.find_subpath('Runner', false)

files_to_add = [
  'StatusBarController.swift',
  'ClipboardMonitor.swift',
  'GlobalShortcut.swift',
  'LaunchAtLogin.swift'
]

files_to_add.each do |file_name|
  # Check if file already in group
  unless runner_group.files.any? { |f| f.path == file_name }
    puts "Adding #{file_name} to project..."
    file_reference = runner_group.new_file(file_name)
    target.add_file_references([file_reference])
  else
    puts "#{file_name} already in project."
  end
end

project.save
puts "Project saved successfully."
