require 'snippet_generator.rb'

RSpec.describe ('initialize_espanso_yml') do 
 it('writes matches and a NEWLINE character') do 
  initialize_espanso_yml("./test.yml")
  expect(File.read("test.yml")).to(eq("matches:"+NEW_LINE)) 
   end 
    end

RSpec.describe ('single_snippet_export') do 
  it('takes arguments provided and inserts them into :trigger and replace respectively, in quotes.  ') do 
    single_snippet_export("test.yml","hello","whats up")
    expect(File.read("test.yml")).to(eq("matches:"+NEW_LINE+"  - trigger: "+"\":hello\"\n    replace: \"whats up\""+NEW_LINE)) 
    end 
      end 

RSpec.describe ('heading_snippet_export') do 
  it('adds a comment line (with a # symbol) at first character') do 
    heading_snippet_export("test.yml","THIS IS A GREAT SECTION")
    expect(File.read("test.yml")).to(eq("matches:"+NEW_LINE+"  - trigger: "+"\":hello\"\n    replace: \"whats up\""+NEW_LINE+"# THIS IS A GREAT SECTION"+NEW_LINE)) 
    end 
      end 

RSpec.describe ('input_form_snippet_export') do 
  it('adds a snippet with form parameters instead.') do 
    input_form_snippet_export("test.yml","aj","aj is {{adjective}}")
    expect(File.read("test.yml")).to(eq("matches:"+NEW_LINE+"  - trigger: "+"\":hello\"\n    replace: \"whats up\""+NEW_LINE+"# THIS IS A GREAT SECTION"+NEW_LINE+"  - trigger: \":aj\""+NEW_LINE+"    form: |"+NEW_LINE+ "      aj is {{adjective}}"+NEW_LINE)) 
    end 
      end 