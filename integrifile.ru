require 'digest'
require 'json'

# Monitors safe directory env
DIR_TO_MONITOR = "./test_directory"
HASH_FILE = "hashes.json"

# Generates SHA256 hash
def compute_sha256(file)
  return nil unless File.file?(file)

  sha256 = Digest::SHA256.new
  File.open(file, "rb") { |f| sha256.update(f.read) }
  sha256.hexdigest
end

# Will scan the directory and then output a hash
def scan_directory(dir)
  hashes = {}
  Dir.glob("#{dir}/**/*").each do |file|
    next unless File.file?(file)

    hashes[file] = compute_sha256(file)
  end
  hashes
end

# Then saves the designated hash to a json file
def save_hashes(hashes)
  File.open(HASH_FILE, "w") { |f| f.write(JSON.pretty_generate(hashes)) }
end

def load_hashes
  return {} unless File.exist?(HASH_FILE)

  JSON.parse(File.read(HASH_FILE))
end

def check_integrity
  old_hashes = load_hashes
  new_hashes = scan_directory(DIR_TO_MONITOR)

  modified = []
  deleted = old_hashes.keys - new_hashes.keys
  added = new_hashes.keys - old_hashes.keys

  new_hashes.each do |file, new_hash|
    if old_hashes[file] && old_hashes[file] != new_hash
      modified << file
    end
  end
  
  # Outputs resules
  puts "\nFile Integrity Check Results:"
  puts "No changes detected." if modified.empty? && deleted.empty? && added.empty?
  puts "Modified files: \n#{modified.join("\n")}" unless modified.empty?
  puts "Deleted files: \n#{deleted.join("\n")}" unless deleted.empty?
  puts "New files added: \n#{added.join("\n")}" unless added.empty?

  save_hashes(new_hashes)
end

# Main man page
def main
  puts "File Integrity Checker"
  puts "[1] Initialize Hashes"
  puts "[2] Check for Changes"
  print "Choose an option: "
  choice = gets.chomp.to_i

  case choice
  when 1
    hashes = scan_directory(DIR_TO_MONITOR)
    save_hashes(hashes)
    puts "Hashes initialized and saved."
  when 2
    check_integrity
  else
    puts "Invalid option."
  end
end

main
