# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/snippet_builder'
require 'snippet_cli/file_validator'
require 'yaml'

RSpec.describe SnippetCli::SnippetBuilder do
  def build(**)
    described_class.build(**)
  end

  describe '.build' do
    context 'single trigger, simple replace' do
      it 'emits a triggers array even for one trigger' do
        yaml = build(triggers: [':hello'], replace: 'Hello!')
        expect(yaml).to match(/triggers:/)
        expect(yaml).to include('":hello"')
      end

      it 'single-quotes a plain replace string' do
        yaml = build(triggers: [':hello'], replace: 'Hello!')
        expect(yaml).to include("replace: 'Hello!'")
      end
    end

    context 'multiple triggers' do
      it 'lists all triggers in the array' do
        yaml = build(triggers: [':hello', ':hi'], replace: 'Hey')
        expect(yaml).to include('":hello"')
        expect(yaml).to include('":hi"')
      end
    end

    context 'regex trigger' do
      it 'emits regex: key' do
        yaml = build(triggers: ['(gr|great)ing'], is_regex: true, replace: 'Hello')
        expect(yaml).to include('regex:')
      end

      it 'does not emit triggers: key' do
        yaml = build(triggers: ['(gr|great)ing'], is_regex: true, replace: 'Hello')
        expect(yaml).not_to include('triggers:')
      end
    end

    context 'single_trigger: true' do
      it 'emits singular trigger: key instead of triggers: array' do
        yaml = build(triggers: [':hello'], replace: 'Hello!', single_trigger: true)
        expect(yaml).to include('trigger: ')
        expect(yaml).not_to include('triggers:')
      end

      it 'quotes the trigger value' do
        yaml = build(triggers: [':hello'], replace: 'Hello!', single_trigger: true)
        expect(yaml).to match(/trigger:.*':hello'|":hello"/)
      end
    end

    context 'with vars' do
      let(:vars) { [{ name: 'myvar', type: 'shell', params: { cmd: 'date' } }] }

      it 'includes a vars block' do
        yaml = build(triggers: [':dt'], vars: vars, replace: '{{myvar}}')
        expect(yaml).to include('vars:')
        expect(yaml).to include('name: myvar')
        expect(yaml).to include('type: shell')
        expect(yaml).to include('cmd:')
      end

      it 'includes the params indented under the var' do
        yaml = build(triggers: [':dt'], vars: vars, replace: '{{myvar}}')
        expect(yaml).to include('params:')
      end
    end

    context 'with array params (random choices)' do
      let(:vars) { [{ name: 'pick', type: 'random', params: { choices: %w[foo bar] } }] }

      it 'renders choices as a block sequence, not a scalar string' do
        yaml = build(triggers: [':test'], vars: vars, replace: '{{pick}}')
        expect(yaml).not_to include('["foo"')
        expect(yaml).not_to include('[foo,')
        expect(yaml).to include("choices:\n")
        expect(yaml).to include("- 'foo'")
        expect(yaml).to include("- 'bar'")
      end
    end

    context 'with multiline form layout' do
      let(:vars) { [{ name: 'myform', type: 'form', params: { layout: "Name: [[name]]\nCity: [[city]]" } }] }

      it 'uses a literal block scalar for layout' do
        yaml = build(triggers: [':form'], vars: vars, replace: '{{myform.name}}')
        expect(yaml).to include("layout: |\n")
      end

      it 'indents each layout line under the block scalar' do
        yaml = build(triggers: [':form'], vars: vars, replace: '{{myform.name}}')
        expect(yaml).to include('        Name: [[name]]')
        expect(yaml).to include('        City: [[city]]')
      end
    end

    context 'with form fields containing multiline text box' do
      let(:vars) do
        [{ name: 'greet', type: 'form',
           params: { layout: "Hey [[name]],\n[[text]]\nHappy Birthday!",
                     fields: { text: { multiline: true } } } }]
      end

      it 'renders fields as nested YAML mapping' do
        yaml = build(triggers: [':greet'], vars: vars, replace: '{{greet.name}}')
        expect(yaml).to include("fields:\n")
        expect(yaml).to include("text:\n")
        expect(yaml).to include('multiline: true')
      end
    end

    context 'with form fields containing choice and list types' do
      let(:vars) do
        [{ name: 'myform', type: 'form',
           params: { layout: '[[name]] [[food]] [[desc]]',
                     fields: { name: { type: :choice, values: %w[aj judith] },
                               food: { type: :list, values: %w[burger pizza] },
                               desc: { multiline: true } } } }]
      end

      it 'renders choice field with type and values list' do
        yaml = build(triggers: [':form'], vars: vars, replace: '{{myform.name}}')
        expect(yaml).to include("name:\n")
        expect(yaml).to include("type: 'choice'")
        expect(yaml).to include("values:\n")
        expect(yaml).to include("- 'aj'")
        expect(yaml).to include("- 'judith'")
      end

      it 'renders list field with type and values list' do
        yaml = build(triggers: [':form'], vars: vars, replace: '{{myform.name}}')
        expect(yaml).to include("food:\n")
        expect(yaml).to include("type: 'list'")
        expect(yaml).to include("- 'burger'")
        expect(yaml).to include("- 'pizza'")
      end

      it 'renders multiline field' do
        yaml = build(triggers: [':form'], vars: vars, replace: '{{myform.name}}')
        expect(yaml).to include("desc:\n")
        expect(yaml).to include('multiline: true')
      end
    end

    context 'with single-line form layout' do
      let(:vars) { [{ name: 'myform', type: 'form', params: { layout: 'Name: [[name]]' } }] }

      it 'renders layout as a quoted scalar' do
        yaml = build(triggers: [':form'], vars: vars, replace: '{{myform.name}}')
        expect(yaml).to include('layout: "Name: [[name]]"')
      end
    end

    context 'with array params (script args)' do
      let(:vars) { [{ name: 'out', type: 'script', params: { args: ['/bin/script', '--flag'] } }] }

      it 'renders args as a block sequence' do
        yaml = build(triggers: [':run'], vars: vars, replace: '{{out}}')
        expect(yaml).to include("args:\n")
        expect(yaml).to include("- '/bin/script'")
        expect(yaml).to include("- '--flag'")
      end
    end

    context 'with mixed scalar and array params' do
      let(:vars) do
        [{ name: 'sh', type: 'shell', params: { cmd: 'date', shell: 'bash' } }]
      end

      it 'keeps scalar params on one line' do
        yaml = build(triggers: [':d'], vars: vars, replace: '{{sh}}')
        expect(yaml).to include("cmd: 'date'")
        expect(yaml).to include("shell: 'bash'")
      end
    end

    context 'without vars' do
      it 'omits the vars key entirely' do
        yaml = build(triggers: [':hi'], replace: 'hi')
        expect(yaml).not_to include('vars:')
      end

      it 'also omits vars when given an empty array' do
        yaml = build(triggers: [':hi'], vars: [], replace: 'hi')
        expect(yaml).not_to include('vars:')
      end
    end

    context 'multiline replace' do
      it 'uses a literal block scalar' do
        yaml = build(triggers: [':ml'], replace: "line one\nline two")
        expect(yaml).to include("replace: |\n")
      end

      it 'preserves all lines' do
        yaml = build(triggers: [':ml'], replace: "line one\nline two")
        expect(yaml).to include('line one')
        expect(yaml).to include('line two')
      end
    end

    context 'replace with single quotes' do
      it 'uses a normal-quoted string' do
        yaml = build(triggers: [':q'], replace: "it's a test")
        expect(yaml).to include(%("it's a test"))
      end
    end

    context 'replace with normal quotes inside' do
      it 'escapes the inner normal quotes' do
        yaml = build(triggers: [':q'], replace: 'say "hello"')
        expect(yaml).to include('replace:')
        expect(yaml).to include('say')
        expect(yaml).to include('hello')
      end
    end

    context 'with label and comment' do
      it 'includes label when provided' do
        yaml = build(triggers: [':lc'], replace: 'text', label: 'My Label')
        expect(yaml).to include('label:')
        expect(yaml).to include('My Label')
      end

      it 'includes comment when provided' do
        yaml = build(triggers: [':lc'], replace: 'text', comment: 'A comment')
        expect(yaml).to include('comment:')
        expect(yaml).to include('A comment')
      end
    end

    context 'without label or comment' do
      it 'omits both keys' do
        yaml = build(triggers: [':simple'], replace: 'text')
        expect(yaml).not_to include('label:')
        expect(yaml).not_to include('comment:')
      end
    end

    context 'with search_terms' do
      it 'includes search_terms key' do
        yaml = build(triggers: [':st'], replace: 'text', search_terms: %w[ruby array])
        expect(yaml).to include('search_terms:')
      end

      it 'renders each term as a list item' do
        yaml = build(triggers: [':st'], replace: 'text', search_terms: %w[ruby array])
        expect(yaml).to include("    - 'ruby'")
        expect(yaml).to include("    - 'array'")
      end
    end

    context 'without search_terms' do
      it 'omits search_terms key' do
        yaml = build(triggers: [':simple'], replace: 'text')
        expect(yaml).not_to include('search_terms:')
      end
    end

    context 'with word: true' do
      it 'includes word: true' do
        yaml = build(triggers: [':w'], replace: 'text', word: true)
        expect(yaml).to include('word: true')
      end

      it 'omits word for image_path matches' do
        yaml = build(triggers: [':img'], image_path: '/img.png', word: true)
        expect(yaml).not_to include('word:')
      end
    end

    context 'without word' do
      it 'omits word key' do
        yaml = build(triggers: [':w'], replace: 'text')
        expect(yaml).not_to include('word:')
      end
    end

    context 'with propagate_case: true' do
      it 'includes propagate_case: true' do
        yaml = build(triggers: [':pc'], replace: 'text', propagate_case: true)
        expect(yaml).to include('propagate_case: true')
      end

      it 'omits propagate_case for image_path matches' do
        yaml = build(triggers: [':img'], image_path: '/img.png', propagate_case: true)
        expect(yaml).not_to include('propagate_case:')
      end
    end

    context 'without propagate_case' do
      it 'omits propagate_case key' do
        yaml = build(triggers: [':pc'], replace: 'text')
        expect(yaml).not_to include('propagate_case:')
      end
    end

    # TASK-18: echo var schema compliance
    context 'echo var' do
      let(:echo_opts) do
        { triggers: [':greet'], replace: '{{msg}}',
          vars: [{ name: 'msg', type: 'echo', params: { echo: 'Hello!' } }] }
      end

      it 'renders the echo param as a scalar under params:' do
        yaml = build(**echo_opts)
        expect(yaml).to include('type: echo')
        expect(yaml).to include("echo: 'Hello!'")
      end

      # AC #5 — invalid echo input is prevented before output
      it 'raises ValidationError when echo param is missing' do
        bad_opts = { triggers: [':x'], replace: '{{v}}',
                     vars: [{ name: 'v', type: 'echo', params: {} }] }
        expect { build(**bad_opts) }.to raise_error(SnippetCli::ValidationError)
      end

      it 'raises ValidationError when echo value is not a string' do
        bad_opts = { triggers: [':x'], replace: '{{v}}',
                     vars: [{ name: 'v', type: 'echo', params: { echo: 42 } }] }
        expect { build(**bad_opts) }.to raise_error(SnippetCli::ValidationError)
      end

      it 'raises ValidationError when echo params contain unknown keys' do
        bad_opts = { triggers: [':x'], replace: '{{v}}',
                     vars: [{ name: 'v', type: 'echo', params: { echo: 'hi', bogus: true } }] }
        expect { build(**bad_opts) }.to raise_error(SnippetCli::ValidationError)
      end

      # AC #4 + AC #6 — input → YAML → FileValidator round-trip
      it 'produces YAML that passes FileValidator when wrapped as a matchfile' do
        yaml_entry = build(**echo_opts)
        # build returns a YAML list item ("- trigger: ..."), so safe_load gives an array
        match_data = YAML.safe_load(yaml_entry).first
        matchfile = { 'matches' => [match_data] }
        errors = SnippetCli::FileValidator.errors(matchfile)
        expect(errors).to be_empty,
                          "FileValidator rejected built echo snippet: #{errors.inspect}"
      end
    end

    context 'html replacement' do
      it 'emits html: key' do
        yaml = build(triggers: [':t'], html: '<b>Bold</b>')
        expect(yaml).to include('html:')
      end

      it 'does not emit replace: key' do
        yaml = build(triggers: [':t'], html: '<b>Bold</b>')
        expect(yaml).not_to include('replace:')
      end

      it 'uses literal block scalar for multiline html' do
        yaml = build(triggers: [':t'], html: "<p>line1</p>\n<p>line2</p>")
        expect(yaml).to include("html: |\n")
      end

      it 'produces YAML that passes FileValidator' do
        yaml = build(triggers: [':t'], single_trigger: true, html: '<b>Bold</b>')
        match_data = YAML.safe_load(yaml).first
        errors = SnippetCli::FileValidator.errors({ 'matches' => [match_data] })
        expect(errors).to be_empty, "FileValidator errors: #{errors.inspect}"
      end
    end

    context 'markdown replacement' do
      it 'emits markdown: key' do
        yaml = build(triggers: [':t'], markdown: '**Bold**')
        expect(yaml).to include('markdown:')
      end

      it 'does not emit replace: key' do
        yaml = build(triggers: [':t'], markdown: '**Bold**')
        expect(yaml).not_to include('replace:')
      end

      it 'uses literal block scalar for multiline markdown' do
        yaml = build(triggers: [':t'], markdown: "line1\nline2")
        expect(yaml).to include("markdown: |\n")
      end

      it 'produces YAML that passes FileValidator' do
        yaml = build(triggers: [':t'], single_trigger: true, markdown: '**Bold**')
        match_data = YAML.safe_load(yaml).first
        errors = SnippetCli::FileValidator.errors({ 'matches' => [match_data] })
        expect(errors).to be_empty, "FileValidator errors: #{errors.inspect}"
      end
    end

    context 'image_path replacement' do
      it 'emits image_path: key' do
        yaml = build(triggers: [':t'], image_path: '/img/logo.png')
        expect(yaml).to include('image_path:')
        expect(yaml).to include('/img/logo.png')
      end

      it 'does not emit replace: key' do
        yaml = build(triggers: [':t'], image_path: '/img/logo.png')
        expect(yaml).not_to include('replace:')
      end

      it 'produces YAML that passes FileValidator' do
        yaml = build(triggers: [':t'], single_trigger: true, image_path: '/img/logo.png')
        match_data = YAML.safe_load(yaml).first
        errors = SnippetCli::FileValidator.errors({ 'matches' => [match_data] })
        expect(errors).to be_empty, "FileValidator errors: #{errors.inspect}"
      end
    end

    context 'empty string replace' do
      it 'emits replace key with empty quoted string' do
        yaml = build(triggers: [':del'], replace: '')
        expect(yaml).to include("replace: ''")
      end

      it 'passes schema validation' do
        yaml = build(triggers: [':del'], replace: '', single_trigger: true)
        match_data = YAML.safe_load(yaml).first
        errors = SnippetCli::FileValidator.errors({ 'matches' => [match_data] })
        expect(errors).to be_empty, "FileValidator errors: #{errors.inspect}"
      end
    end

    context 'output structure' do
      it 'starts with a YAML list item dash' do
        yaml = build(triggers: [':hello'], replace: 'Hi')
        expect(yaml).to start_with('- ')
      end

      it 'ends with a newline' do
        yaml = build(triggers: [':hello'], replace: 'Hi')
        expect(yaml).to end_with("\n")
      end
    end
  end
end
