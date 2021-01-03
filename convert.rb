#!/usr/bin/env ruby

require 'zip'
require 'tmpdir'

prgname = 'blockscad_obj_mtl_converter'
prgurl = 'https://github.com/dennisschuerholz/blockscad_obj_mtl_converter'
prgauthors = 'Dennis Schürholz'

abort "This script requires an .obj-File to convert as first parameter." if ARGV.empty?

inputfile = ARGV[0]
zipfile = File.basename(inputfile, '.*') + '.zip'
objfile = 'blockscad.obj'
mtlfile = 'blockscad.mtl'

abort "This script will only work on .obj-Files (3D Objects exported from blockscad3d.com)" unless File.extname(inputfile) == '.obj'

Dir.mktmpdir prgname do |dir|
  open("#{dir}/#{objfile}", 'w') do |obj|
    obj.puts "# Object converted using #{prgname} (#{prgurl} written by #{prgauthors})"
    obj.puts ""
    obj.puts "mtllib #{mtlfile}"
    obj.puts ""
    open("#{dir}/#{mtlfile}", 'w') do |mtl|
      mtl.puts "# Material generated using #{prgname} (#{prgurl} written by #{prgauthors})"

      File.readlines(inputfile).each do |line|
        if line.start_with? 'g '
          grpname = line.gsub(/g /, '')
          r, g, b, a = grpname.split '-'
          mtl.puts ""
          mtl.puts "newmtl color-#{grpname}"
          mtl.puts "Ka 0 0 0"
          mtl.puts "Kd #{r.to_i / 255.0} #{g.to_i / 255.0} #{b.to_i / 255.0}"
          mtl.puts "d #{a.to_i}"
          mtl.puts "illum 0.0"

          obj.puts ""
          obj.puts line
          obj.puts "usemtl color-#{grpname}"
          obj.puts ""
        else
          obj.puts line
        end
      end
    end
  end
  Zip::ZipFile.open(zipfile, Zip::ZipFile::CREATE) do |zip|
    zip.add(objfile, "#{dir}/#{objfile}")
    zip.add(mtlfile, "#{dir}/#{mtlfile}")
  end
end
