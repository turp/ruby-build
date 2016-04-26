# build

Build script library that uses ruby to automate common continuous integration tasks

## Pre-Requisites
IronRuby is used for running the build scripts. It can be installed from [http://ironruby.codeplex.com/releases](http://ironruby.codeplex.com/releases)

## Example


	require 'build/build'
	
	welcome 'Fowler\'s Video Store'

	make do |m|
		m.update_assembly_info do |t|
			t.version = version()
		end

		m.compile do |t|
			t.solution = "src/VideoStore.sln" 
			t.log = "logs/compile.txt" 
		end
	
		#	m.mstest do |t|
		#		#t.path "C:/Program Files/Microsoft Visual Studio 11.0/Common7/IDE/mstest.exe"
		#		t.assemblies << "src/Tests/bin/release/Tests.dll"
		#	end
	
		m.nunit do |t|
			t.library = "src/Tests/bin/Tests.dll"
			t.nunit_path = "src/packages/NUnit.2.5.10.11092/tools/nunit-console-x86.exe"
			t.log = "logs/test.output.xml"
		end
	end

	box do |b|
		b.copy do |t|
			t.from = 'src/VideoStore'	
			t.to = "builds/#{version()}/Web"
			t.exclude.directories = ["obj", "Libraries"]
			t.exclude.files = ["*.cs", "*.pdb", "*.log", "*.csproj"]
		end
	
		b.copy do |t|
			t.from = 'src/Reports'	
			t.to = "builds/#{version()}/Reports"
			t.exclude.files = ["*.rdl", "*.rds"]
		end
	
		b.copy do |t|
			t.from = 'db/Northwind/migrations'
			t.to = "builds/#{version()}/Database/migrations"
		end
		
		b.combine do |t|
			t.from = 'db/Northwind'	
			t.to = "builds/#{version()}/Database/Db.App.Script.sql"
			t.include.directories = ["Functions", "Views", "Triggers", "Procedures"]
			t.include.files = ["*.SQL"]
		end
	end
	
	ship do |d|
		d.database do |db|
			db.server = '(local)\\SQLEXPRESS'
			db.name = 'Northwind'
	
			db.create_db_if_it_does_not_exist
			
			db.restore do |t|
				t.backup_file = "db/Backup/Northwind.zip"
				t.restore_path = "c:/temp" 
			end
		
			db.set_recovery_mode 'simple'
			
			db.backup do |t|
				t.path = "c:/temp"
				t.compress = false
			end
	
			db.migrate do |t|
				t.path = "builds/#{version()}/Database/migrations"
			end
		
			db.execute_script "builds/#{version()}/Database/Db.App.Script.sql"
		end
		
		d.ssrs do |reports|
			reports.copy do |t|
				t.from = "builds/#{version()}/Reports"
				t.to = "c:/temp/Reports"			
			end
		end
		
		d.web do |w|
			w.copy do |t|
				t.from = "builds/#{version()}/Web"
				t.to = "c:/temp/Demo"
			end	
		end
	end

