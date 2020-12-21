# Some Definitions for the sake of readability.
module SnippetGenerator.
  NEW_LINE="\n"
    QUOTE = '"'

  #Just writes matches: at the beginning of file so espanso can read the mapping.

      def initialize_espanso_yml(file_to_write)
        File.open(file_to_write,"a") { |file| file.write('matches:'+NEW_LINE) }
      end

  #Writes a snippet to file when given trigger and replacement strings.

      def single_snippet_export(file_to_write,trigger,replacement)
        File.open(file_to_write,"a") { |file| file.write('  - trigger: '+'":'+trigger+QUOTE+NEW_LINE) }
        File.open(file_to_write,"a") { |file| file.write('    replace: '+QUOTE+replacement+QUOTE+NEW_LINE) }
      end

  # Create a YAML Comment to separate sections of snippet file.

  def heading_snippet_export(file_to_write,heading)
    File.open(file_to_write,"a") { |file| file.write("# "+ heading+NEW_LINE) }     
  end

  # Any input fields should be entered with double brackets around them when passed in as form_statement
  # For example "AJ likes coding in {{language}} and using {{editor}} to write code."

  def input_form_snippet_export(file_to_write, form_trigger,form_statement)
    File.open(file_to_write,"a") { |file| file.write('  - trigger: '+QUOTE+':'+form_trigger+QUOTE+NEW_LINE) }
    File.open(file_to_write,"a") { |file| file.write('    form: |'+NEW_LINE)}
    File.open(file_to_write,"a") { |file| file.write('      '+form_statement+NEW_LINE)}
  end
  ## ! TO DO: REFACTOR FORM METHODS INTO ONE METHOD which accounts for all cases. Add comments clarifying
  ## ! DATA STRUCTURE NEEDED.
  #Takes a string for trigger. form_values should be an array.form_fields should also be of type array.
  #Parses statements and creates picklists based on form fields and values for each field provided 

      def picklist_snippet_export(form_trigger,statement,form_fields,formvalues,file_to_write)
        form_fields.each do |value|
          value+':'
        end
        form_type = 'choice'
        File.open(file_to_write,"a") { |file| file.write('  - trigger: '+'":'+form_trigger+QUOTE+NEW_LINE) }
        File.open(file_to_write,"a") { |file| file.write('    form: '+QUOTE+statement+QUOTE+NEW_LINE) }
        form_fields.each do |value|
          File.open(file_to_write,"a") { |file| file.write('    form_fields:'+NEW_LINE) }
          File.open(file_to_write,"a") { |file| file.write('      '+form_fields+NEW_LINE) }
          File.open(file_to_write,"a") { |file| file.write('       type: '+ form_type+NEW_LINE) }
          File.open(file_to_write,"a") { |file| file.write('       values:'+NEW_LINE) }
          formvalues.each do |value|
            File.open(file_to_write,"a") { |file| file.write('          - '+QUOTE+value+QUOTE+NEW_LINE) }
          end
        end

      end

  # Creates a snippet with large text box

        def textarea_snippet_export(file_to_write)
          File.open(file_to_write,"a") { |file| file.write('  - trigger: '+QUOTE+':'+form_trigger+QUOTE+NEW_LINE) }
          File.open(file_to_write,"a") { |file| file.write('    form: |'+NEW_LINE)}
          File.open(file_to_write,"a") { |file| file.write('      '+form_statement+NEW_LINE)}
          File.open(file_to_write,"a") { |file| file.write('        '+field_names+NEW_LINE) }
          File.open(file_to_write,"a") { |file| file.write('          '+"multiline: true"+NEW_LINE) }
        end

  ## Form Generator Method. Will make form that has, .
  ## Takes a few arrays as arguments.
  ## Form Fields: Just string in array, but in form context represented as {{Form Field Name}}
end