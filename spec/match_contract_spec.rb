# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/match_validator'

RSpec.describe SnippetCli::MatchValidator do
  def valid?(data)
    described_class.valid?(data)
  end

  def errors(data)
    described_class.errors(data)
  end

  context 'valid matches' do
    it 'accepts a single trigger with replace' do
      expect(valid?(trigger: ':ty', replace: 'Thank you')).to be true
    end

    it 'accepts triggers array with replace' do
      expect(valid?(triggers: [':ty', ':thankyou'], replace: 'Thank you')).to be true
    end

    it 'accepts regex with replace' do
      expect(valid?(regex: '\bty\b', replace: 'Thank you')).to be true
    end

    it 'accepts a match with label and comment' do
      expect(valid?(trigger: ':ty', replace: 'Thank you', label: 'Greeting', comment: 'A polite response')).to be true
    end

    it 'accepts a match with vars' do
      data = {
        trigger: ':now',
        replace: '{{ts}}',
        vars: [{ name: 'ts', type: 'date', params: { format: '%H:%M' } }]
      }
      expect(valid?(data)).to be true
    end

    it 'accepts a match with word and propagate_case' do
      expect(valid?(trigger: ':ty', replace: 'Thank you', word: true, propagate_case: true)).to be true
    end
  end

  context 'missing trigger' do
    it 'fails when no trigger, triggers, or regex is provided' do
      expect(valid?(replace: 'Thank you')).to be false
    end

    it 'includes a descriptive error' do
      errs = errors(replace: 'Thank you')
      expect(errs.join(' ')).to match(/trigger|triggers|regex/i)
    end
  end

  context 'missing replacement' do
    it 'fails when no replace, form, or image_path is provided' do
      expect(valid?(trigger: ':ty')).to be false
    end
  end

  context 'mutually exclusive triggers' do
    it 'fails when both trigger and triggers are provided' do
      expect(valid?(trigger: ':ty', triggers: [':thankyou'], replace: 'Thank you')).to be false
    end

    it 'fails when both trigger and regex are provided' do
      expect(valid?(trigger: ':ty', regex: '\bty\b', replace: 'Thank you')).to be false
    end

    it 'fails when both triggers and regex are provided' do
      expect(valid?(triggers: [':ty'], regex: '\bty\b', replace: 'Thank you')).to be false
    end
  end

  context 'mutually exclusive replacements' do
    it 'fails when both replace and form are provided' do
      expect(valid?(trigger: ':ty', replace: 'Thank you', form: 'Enter [[name]]')).to be false
    end

    it 'fails when both replace and image_path are provided' do
      expect(valid?(trigger: ':ty', replace: 'Thank you', image_path: '/tmp/img.png')).to be false
    end
  end

  context 'triggers validation' do
    it 'fails when triggers is an empty array' do
      expect(valid?(triggers: [], replace: 'Thank you')).to be false
    end

    it 'fails when trigger is an empty string' do
      expect(valid?(trigger: '', replace: 'Thank you')).to be false
    end
  end

  context 'vars validation' do
    it 'fails when a var is missing name' do
      data = { trigger: ':x', replace: '{{out}}', vars: [{ type: 'shell', params: { cmd: 'date' } }] }
      expect(valid?(data)).to be false
    end

    it 'fails when a var is missing type' do
      data = { trigger: ':x', replace: '{{out}}', vars: [{ name: 'out', params: { cmd: 'date' } }] }
      expect(valid?(data)).to be false
    end

    it 'fails when a var is missing params' do
      data = { trigger: ':x', replace: '{{out}}', vars: [{ name: 'out', type: 'shell' }] }
      expect(valid?(data)).to be false
    end

    it 'fails when var type is not a recognized Espanso extension' do
      data = { trigger: ':x', replace: '{{out}}',
               vars: [{ name: 'out', type: 'invalid_type', params: { cmd: 'date' } }] }
      expect(valid?(data)).to be false
    end

    it 'accepts echo var with optional trim: true' do
      data = { trigger: ':x', replace: '{{out}}',
               vars: [{ name: 'out', type: 'echo', params: { echo: 'hello', trim: true } }] }
      expect(valid?(data)).to be(true)
    end

    it 'accepts echo var with optional trim: false' do
      data = { trigger: ':x', replace: '{{out}}',
               vars: [{ name: 'out', type: 'echo', params: { echo: 'hello', trim: false } }] }
      expect(valid?(data)).to be(true)
    end

    it 'rejects echo var with non-boolean trim' do
      data = { trigger: ':x', replace: '{{out}}',
               vars: [{ name: 'out', type: 'echo', params: { echo: 'hello', trim: 'yes' } }] }
      expect(valid?(data)).to be(false)
    end

    it 'accepts a date var with a valid BCP47 locale' do
      data = { trigger: ':x', replace: '{{out}}',
               vars: [{ name: 'out', type: 'date', params: { format: '%Y-%m-%d', locale: 'en-US' } }] }
      expect(valid?(data)).to be(true)
    end

    it 'accepts a date var with locale ja-JP' do
      data = { trigger: ':x', replace: '{{out}}',
               vars: [{ name: 'out', type: 'date', params: { format: '%Y-%m-%d', locale: 'ja-JP' } }] }
      expect(valid?(data)).to be(true)
    end

    it 'accepts a date var with an offset integer' do
      data = { trigger: ':x', replace: '{{out}}',
               vars: [{ name: 'out', type: 'date', params: { format: '%Y-%m-%d', offset: 86_400 } }] }
      expect(valid?(data)).to be(true)
    end

    it 'rejects a date var with a non-integer offset' do
      data = { trigger: ':x', replace: '{{out}}',
               vars: [{ name: 'out', type: 'date', params: { format: '%Y-%m-%d', offset: '1day' } }] }
      expect(valid?(data)).to be(false)
    end

    it 'accepts all valid var types with appropriate params' do
      type_params = {
        'clipboard' => {},
        'choice' => { values: %w[a b] },
        'date' => { format: '%Y-%m-%d' },
        'echo' => { echo: 'hello' },
        'form' => { layout: 'Enter [[name]]' },
        'global' => {},
        'random' => { choices: %w[a b] },
        'script' => { args: ['/bin/echo', 'hi'] },
        'shell' => { cmd: 'date' }
      }

      type_params.each do |var_type, params|
        data = { trigger: ':x', replace: '{{out}}', vars: [{ name: 'out', type: var_type, params: params }] }
        expect(valid?(data)).to be(true),
                                "expected var type '#{var_type}' to be valid, errors: #{errors(data).inspect}"
      end
    end
  end

  describe '.errors' do
    it 'returns an empty array for valid data' do
      expect(errors(trigger: ':ty', replace: 'Thank you')).to be_empty
    end

    it 'returns human-readable error strings for invalid data' do
      errs = errors({})
      expect(errs).to be_an(Array)
      expect(errs).not_to be_empty
      errs.each { |e| expect(e).to be_a(String) }
    end
  end
end
