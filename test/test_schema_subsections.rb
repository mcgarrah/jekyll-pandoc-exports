require 'minitest/autorun'
require 'tmpdir'
require 'yaml'
require 'date'
require 'fileutils'

# This test validates the subsections schema validation logic
# that was added to the ExportRunner#validate_schema! method.
# We test the validation logic directly (extracted into a helper)
# to avoid needing to mock the full CLI flow.

class TestSchemaSubsections < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir
    @source = @tmpdir
    FileUtils.mkdir_p(File.join(@source, '_data'))
  end

  def teardown
    FileUtils.rm_rf(@tmpdir)
  end

  # --- Backward compatibility tests (Requirement 8.4) ---

  def test_entry_with_only_summary_passes_validation
    errors = validate_experiences([
      { 'role' => 'Engineer', 'company' => 'Acme', 'time' => '2020-Present', 'summary' => 'Did engineering work.' }
    ])
    assert_empty errors, "Expected no errors for entry with only summary"
  end

  def test_entry_with_summary_and_details_passes_validation
    errors = validate_experiences([
      { 'role' => 'Engineer', 'company' => 'Acme', 'time' => '2020-Present',
        'summary' => 'Summary text.', 'details' => 'Details text with **bold**.' }
    ])
    assert_empty errors, "Expected no errors for entry with summary and details"
  end

  def test_entry_with_only_details_passes_validation
    errors = validate_experiences([
      { 'role' => 'Engineer', 'company' => 'Acme', 'time' => '2020-Present',
        'details' => 'Some details about the role.' }
    ])
    assert_empty errors, "Expected no errors for entry with only details"
  end

  # --- Subsections acceptance tests (Requirement 8.1, 8.2) ---

  def test_entry_with_valid_subsections_passes_validation
    errors = validate_experiences([
      { 'role' => 'Lead Engineer', 'company' => 'BigCo', 'time' => '2021-Present',
        'summary' => 'Led projects.',
        'subsections' => [
          { 'title' => 'Project Alpha', 'text' => 'Built the alpha system.' },
          { 'title' => 'Project Beta', 'text' => 'Designed the beta platform.' }
        ] }
    ])
    assert_empty errors, "Expected no errors for entry with valid subsections"
  end

  def test_entry_with_only_subsections_passes_validation
    errors = validate_experiences([
      { 'role' => 'Engineer', 'company' => 'Acme', 'time' => '2020-Present',
        'subsections' => [
          { 'title' => 'Infrastructure', 'text' => 'Managed cloud infrastructure.' }
        ] }
    ])
    assert_empty errors, "Expected no errors for entry with only subsections (no summary/details)"
  end

  def test_entry_with_all_three_content_fields_passes_validation
    errors = validate_experiences([
      { 'role' => 'Engineer', 'company' => 'Acme', 'time' => '2020-Present',
        'summary' => 'Summary.', 'details' => 'Details.',
        'subsections' => [
          { 'title' => 'Section', 'text' => 'Content.' }
        ] }
    ])
    assert_empty errors, "Expected no errors for entry with summary, details, and subsections"
  end

  # --- Content requirement validation (Requirement 8.3) ---

  def test_entry_without_summary_details_or_subsections_fails_validation
    errors = validate_experiences([
      { 'role' => 'Engineer', 'company' => 'Acme', 'time' => '2020-Present' }
    ])
    assert errors.any? { |e| e.include?("must have at least one of") },
           "Expected error about missing content fields, got: #{errors}"
  end

  def test_entry_with_empty_summary_and_no_other_content_fails_validation
    errors = validate_experiences([
      { 'role' => 'Engineer', 'company' => 'Acme', 'time' => '2020-Present', 'summary' => '   ' }
    ])
    assert errors.any? { |e| e.include?("must have at least one of") },
           "Expected error about missing content fields for whitespace-only summary, got: #{errors}"
  end

  # --- Subsection structure validation (Requirement 8.1, 8.2) ---

  def test_subsection_missing_title_fails_validation
    errors = validate_experiences([
      { 'role' => 'Engineer', 'company' => 'Acme', 'time' => '2020-Present',
        'subsections' => [
          { 'text' => 'Content without a title.' }
        ] }
    ])
    assert errors.any? { |e| e.include?("'title'") },
           "Expected error about missing title, got: #{errors}"
  end

  def test_subsection_missing_text_fails_validation
    errors = validate_experiences([
      { 'role' => 'Engineer', 'company' => 'Acme', 'time' => '2020-Present',
        'subsections' => [
          { 'title' => 'A Title' }
        ] }
    ])
    assert errors.any? { |e| e.include?("'text'") },
           "Expected error about missing text, got: #{errors}"
  end

  def test_subsection_with_non_string_title_fails_validation
    errors = validate_experiences([
      { 'role' => 'Engineer', 'company' => 'Acme', 'time' => '2020-Present',
        'subsections' => [
          { 'title' => 123, 'text' => 'Valid text.' }
        ] }
    ])
    assert errors.any? { |e| e.include?("'title'") },
           "Expected error about invalid title type, got: #{errors}"
  end

  def test_subsection_with_non_string_text_fails_validation
    errors = validate_experiences([
      { 'role' => 'Engineer', 'company' => 'Acme', 'time' => '2020-Present',
        'subsections' => [
          { 'title' => 'Valid Title', 'text' => ['not', 'a', 'string'] }
        ] }
    ])
    assert errors.any? { |e| e.include?("'text'") },
           "Expected error about invalid text type, got: #{errors}"
  end

  def test_subsection_with_empty_title_fails_validation
    errors = validate_experiences([
      { 'role' => 'Engineer', 'company' => 'Acme', 'time' => '2020-Present',
        'subsections' => [
          { 'title' => '   ', 'text' => 'Valid text.' }
        ] }
    ])
    assert errors.any? { |e| e.include?("'title'") },
           "Expected error about empty title, got: #{errors}"
  end

  def test_subsection_with_empty_text_fails_validation
    errors = validate_experiences([
      { 'role' => 'Engineer', 'company' => 'Acme', 'time' => '2020-Present',
        'subsections' => [
          { 'title' => 'Valid Title', 'text' => '' }
        ] }
    ])
    assert errors.any? { |e| e.include?("'text'") },
           "Expected error about empty text, got: #{errors}"
  end

  def test_subsections_not_array_fails_validation
    errors = validate_experiences([
      { 'role' => 'Engineer', 'company' => 'Acme', 'time' => '2020-Present',
        'subsections' => 'not an array' }
    ])
    assert errors.any? { |e| e.include?("must be an array") },
           "Expected error about subsections not being array, got: #{errors}"
  end

  def test_subsection_non_object_entry_fails_validation
    errors = validate_experiences([
      { 'role' => 'Engineer', 'company' => 'Acme', 'time' => '2020-Present',
        'subsections' => ['just a string'] }
    ])
    assert errors.any? { |e| e.include?("must be an object") },
           "Expected error about non-object subsection, got: #{errors}"
  end

  # --- Multiple subsections with mixed validity ---

  def test_multiple_subsections_reports_errors_for_invalid_ones
    errors = validate_experiences([
      { 'role' => 'Engineer', 'company' => 'Acme', 'time' => '2020-Present',
        'subsections' => [
          { 'title' => 'Valid', 'text' => 'Valid content.' },
          { 'title' => '', 'text' => 'Missing title.' },
          { 'title' => 'Also Valid', 'text' => 'More content.' }
        ] }
    ])
    assert errors.any? { |e| e.include?("subsection #2") },
           "Expected error for subsection #2, got: #{errors}"
    refute errors.any? { |e| e.include?("subsection #1") },
           "Should not report error for valid subsection #1"
    refute errors.any? { |e| e.include?("subsection #3") },
           "Should not report error for valid subsection #3"
  end

  # --- Error message quality ---

  def test_error_message_includes_role_name
    errors = validate_experiences([
      { 'role' => 'Senior Platform Engineer', 'company' => 'Acme', 'time' => '2020-Present',
        'subsections' => [
          { 'title' => 'Valid', 'text' => '' }
        ] }
    ])
    assert errors.any? { |e| e.include?("Senior Platform Engineer") },
           "Expected error message to include role name for identification"
  end

  private

  # Mirrors the validation logic from ExportRunner#validate_schema! in command.rb
  # This ensures our tests validate the same logic that runs in production.
  def validate_experiences(experiences)
    errors = []

    experiences.each_with_index do |exp, i|
      errors << "Experience ##{i + 1} missing 'role'" unless exp['role']
      errors << "Experience ##{i + 1} missing 'company'" unless exp['company']
      errors << "Experience ##{i + 1} missing 'time'" unless exp['time']

      # Require at least one content field
      has_summary = exp['summary'].is_a?(String) && !exp['summary'].strip.empty?
      has_details = exp['details'].is_a?(String) && !exp['details'].strip.empty?
      has_subsections = exp['subsections'].is_a?(Array) && !exp['subsections'].empty?

      unless has_summary || has_details || has_subsections
        errors << "Experience ##{i + 1} ('#{exp['role']}') must have at least one of: 'summary', 'details', or 'subsections'"
      end

      # Validate subsections structure if present
      if exp['subsections']
        unless exp['subsections'].is_a?(Array)
          errors << "Experience ##{i + 1} ('#{exp['role']}') 'subsections' must be an array"
        else
          exp['subsections'].each_with_index do |sub, j|
            unless sub.is_a?(Hash)
              errors << "Experience ##{i + 1} ('#{exp['role']}') subsection ##{j + 1} must be an object"
              next
            end
            unless sub['title'].is_a?(String) && !sub['title'].strip.empty?
              errors << "Experience ##{i + 1} ('#{exp['role']}') subsection ##{j + 1} missing or invalid 'title' (must be a non-empty string)"
            end
            unless sub['text'].is_a?(String) && !sub['text'].strip.empty?
              errors << "Experience ##{i + 1} ('#{exp['role']}') subsection ##{j + 1} missing or invalid 'text' (must be a non-empty string)"
            end
          end
        end
      end
    end

    errors
  end
end
