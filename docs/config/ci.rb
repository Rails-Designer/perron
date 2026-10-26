# Run using bin/ci

CI.run do
  step "Setup", "bin/setup --skip-server"

  step "Style: Ruby", "bin/rubocop"

  step "Zeitwerk", "bundle exec rails zeitwerk:check"

  step "Security: Importmap vulnerability audit", "bin/importmap audit"
  step "Tests: Rails", "bin/rails test"

  step "Perron: validate", "bin/rails perron:validate"
end
