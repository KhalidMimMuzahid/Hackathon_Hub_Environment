# Submission System Testing Guide

This document outlines the comprehensive testing strategy for the project submission system.

## Overview

The submission system has been thoroughly tested with:
- **Backend API Tests**: Testing all submission endpoints and business logic
- **Frontend Component Tests**: Testing UI components and user interactions
- **Integration Tests**: Testing complete workflows from start to finish
- **Edge Case Tests**: Testing error handling and permission enforcement

## Test Structure

### Backend Tests (`onchain_fastapi/tests/`)

1. **`test_submissions.py`** - Unit tests for submission APIs
   - Project submission endpoints
   - Module submission endpoints
   - Submittal submission endpoints
   - Permission validation
   - Error handling

2. **`test_submission_integration.py`** - Integration workflow tests
   - Complete user journey from project discovery to submission
   - Cross-module data validation
   - Permission enforcement across the workflow
   - Data integrity and consistency

### Frontend Tests (`hub_nextjs/__tests__/`)

1. **`submissions.test.tsx`** - Component and interaction tests
   - Projects listing page with filtering
   - Project detail page with start functionality
   - Module detail page with submission interface
   - Submissions management page
   - Error states and loading indicators

## Running Tests

### Quick Start
```bash
# Run all tests
./test_runner.py

# Or with Python
python test_runner.py
```

### Individual Test Suites

#### Backend Tests
```bash
cd onchain_fastapi

# Run submission API tests
python -m pytest tests/test_submissions.py -v

# Run integration tests
python -m pytest tests/test_submission_integration.py -v

# Run with coverage
python -m pytest tests/ --cov=app.modules.submissions --cov-report=html
```

#### Frontend Tests
```bash
cd hub_nextjs

# Run submission component tests
npm test -- __tests__/submissions.test.tsx --watchAll=false

# Run all tests with coverage
npm test -- --coverage --watchAll=false

# Type checking
npm run type-check

# Linting
npm run lint
```

## Test Coverage

### Backend API Endpoints Tested
- `POST /api/v1/submissions/projects/start_project`
- `GET /api/v1/submissions/projects/get_project_submission`
- `GET /api/v1/submissions/projects/get_my_project_submissions`
- `POST /api/v1/submissions/modules/start_module`
- `GET /api/v1/submissions/modules/get_module_submission`
- `GET /api/v1/submissions/modules/get_my_module_submissions`
- `POST /api/v1/submissions/submittals/create_submission`
- `PUT /api/v1/submissions/submittals/update_submission`
- `GET /api/v1/submissions/submittals/get_submission`
- `GET /api/v1/submissions/submittals/get_my_submissions`

### Frontend Components Tested
- `ProjectsPage` - Project listing with start functionality
- `ProjectDetailPage` - Project details with module access
- `ModuleDetailPage` - Module details with submittal interface
- `SubmissionsPage` - User submission management

### Key Test Scenarios

1. **Project Discovery and Starting**
   - User browses projects with filtering
   - User starts a project (permission checks)
   - UI updates reflect started status

2. **Module Progression**
   - User views project modules
   - User starts modules (requires project start)
   - Module status tracking

3. **Submittal Completion**
   - User submits different types (text, link, file)
   - Validation for required submission types
   - Duplicate submission prevention

4. **Permission Enforcement**
   - Project creators cannot start own projects
   - Sequential workflow enforcement (project → module → submittal)
   - Cross-project module validation

5. **Error Handling**
   - API error responses
   - Network failures
   - Invalid data submissions
   - Permission violations

## Test Data Setup

The tests use fixtures to create:
- Test users (creators and participants)
- Test projects with different configurations
- Test modules with various types
- Test submittals (text, link, file types)

## Continuous Integration

The test suite is designed to run in CI/CD environments:

```yaml
# Example GitHub Actions workflow
name: Test Submission System
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup Python
        uses: actions/setup-python@v2
        with:
          python-version: '3.9'
      - name: Setup Node.js
        uses: actions/setup-node@v2
        with:
          node-version: '16'
      - name: Install dependencies
        run: |
          cd onchain_fastapi && pip install -r requirements.txt
          cd ../hub_nextjs && npm install
      - name: Run tests
        run: ./test_runner.py
```

## Test Reports

After running tests, check these locations for detailed reports:

- **Backend Coverage**: `onchain_fastapi/htmlcov/index.html`
- **Frontend Coverage**: `hub_nextjs/coverage/lcov-report/index.html`
- **Test Summary**: `TEST_REPORT.md`

## Debugging Failed Tests

### Backend Test Failures
1. Check database connection and migrations
2. Verify test data setup in fixtures
3. Check API endpoint implementations
4. Review error logs in test output

### Frontend Test Failures
1. Check component imports and mocks
2. Verify Redux store setup
3. Check API hook mocking
4. Review component rendering logic

### Integration Test Failures
1. Verify backend server is running
2. Check API endpoint availability
3. Review workflow step dependencies
4. Check data persistence between steps

## Adding New Tests

### Backend Tests
1. Add test functions to existing test files
2. Use existing fixtures for data setup
3. Follow naming convention: `test_<functionality>`
4. Include both success and failure cases

### Frontend Tests
1. Add test cases to `submissions.test.tsx`
2. Mock API responses appropriately
3. Test user interactions with `fireEvent`
4. Verify UI state changes with `waitFor`

## Performance Testing

For performance testing of the submission system:

```bash
# Load testing with locust (if installed)
cd onchain_fastapi
locust -f tests/load_test.py --host=http://localhost:8000

# Frontend performance testing
cd hub_nextjs
npm run build
npm run start
# Use Lighthouse or similar tools
```

## Security Testing

Security considerations tested:
- Authentication and authorization
- Input validation and sanitization
- SQL injection prevention
- Cross-site scripting (XSS) prevention
- File upload security

## Maintenance

- Run tests before each deployment
- Update tests when adding new features
- Review test coverage regularly
- Keep test data fixtures up to date
- Monitor test execution time and optimize as needed

## Troubleshooting

### Common Issues

1. **Database connection errors**
   - Ensure test database is running
   - Check connection string in test config

2. **Import errors**
   - Verify all dependencies are installed
   - Check Python path and module imports

3. **Timeout errors**
   - Increase timeout values for slow operations
   - Check for infinite loops or blocking operations

4. **Mock failures**
   - Verify mock setup matches actual API
   - Check mock return values and side effects

For additional help, check the test output logs and error messages for specific guidance.
