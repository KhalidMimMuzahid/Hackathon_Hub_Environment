# Judge System Documentation

## Overview

The Judge System is a comprehensive solution for managing project judges, handling invitations, and facilitating the judging process. It includes both backend APIs and frontend interfaces for complete judge management.

## Features

### ✅ **Complete Backend Implementation**
- **Judge Assignment**: Assign judges to projects with customizable permissions
- **Invitation System**: Send invitations with personal messages
- **Permission Management**: Control what judges can do (score modules, view submissions)
- **Judge Panel**: Dedicated dashboard for judges to manage their assignments
- **Invitation Acceptance**: Accept or decline judge invitations
- **Comprehensive APIs**: Full CRUD operations with proper validation

### ✅ **Frontend Integration**
- **Judge Assignment Modal**: User-friendly interface for assigning judges
- **Judge List Table**: Display and manage project judges
- **Judge Panel Dashboard**: Dedicated page for judges to manage invitations
- **Permission Controls**: Intuitive checkboxes for permission management
- **Invitation Messages**: Personal message support for judge invitations

### ✅ **Testing Suite**
- **Backend Tests**: Comprehensive API testing with pytest
- **Frontend Tests**: Component testing with Jest and React Testing Library
- **Integration Tests**: End-to-end workflow testing
- **Error Handling**: Robust error handling and validation

## API Endpoints

### Judge Assignment
```
POST /api/v1/projects/judges/assign
```
Assign a judge to a project with permissions and optional invitation message.

**Request Body:**
```json
{
  "projectId": 1,
  "judgeUserId": 2,
  "canScoreModules": true,
  "canViewAllSubmissions": true,
  "invitationMessage": "Welcome to the project!"
}
```

### Get Project Judges
```
GET /api/v1/projects/judges/{project_id}
```
Retrieve all judges assigned to a specific project.

### Update Judge Permissions
```
PUT /api/v1/projects/judges/{judge_id}
```
Update judge permissions and settings.

### Remove Judge
```
DELETE /api/v1/projects/judges/{judge_id}
```
Remove a judge from a project.

### Accept/Decline Invitation
```
POST /api/v1/projects/judges/invitation/accept
```
Accept or decline a judge invitation.

**Request Body:**
```json
{
  "projectId": 1,
  "accept": true
}
```

### Judge Panel APIs
```
GET /api/v1/projects/judges/panel/projects
GET /api/v1/projects/judges/panel/summary
```
Get judge assignments and invitation summary for the judge panel.

## Frontend Components

### JudgeAssignmentModal
Modal component for assigning judges to projects.

**Props:**
- `isOpen`: Boolean to control modal visibility
- `onClose`: Function to close the modal
- `projectId`: ID of the project
- `onJudgeAssigned`: Callback when judge is successfully assigned

**Features:**
- User search functionality
- Permission checkboxes
- Invitation message field
- Real-time validation

### JudgeListTable
Table component to display and manage project judges.

**Props:**
- `judges`: Array of judge objects
- `onJudgeUpdated`: Callback when judge is updated
- `canManageJudges`: Boolean for permission control

**Features:**
- Judge information display
- Status badges (accepted/pending)
- Permission indicators
- Edit/Remove actions

### Judge Panel Page
Dedicated page for judges to manage their assignments.

**Features:**
- Invitation summary cards
- Project list with details
- Accept/Decline actions
- Project navigation

## Database Schema

### ProjectJudge Model
```python
class ProjectJudge(Base):
    id: int
    projectId: int
    judgeUserId: int
    assignedByUserId: int
    canScoreModules: bool
    canViewAllSubmissions: bool
    invitationAccepted: bool
    invitationMessage: str (optional)
    isActive: bool
    createdAt: datetime
    updatedAt: datetime
```

## Usage Examples

### 1. Assign a Judge
```typescript
const { assignJudge } = useJudges();

const assignJudgeToProject = async () => {
  const result = await assignJudge({
    projectId: 1,
    judgeUserId: 2,
    canScoreModules: true,
    canViewAllSubmissions: true,
    invitationMessage: "Welcome to the project!"
  });
  
  if (result) {
    console.log("Judge assigned successfully");
  }
};
```

### 2. Accept an Invitation
```typescript
const { acceptInvitation } = useJudges();

const handleInvitation = async (accept: boolean) => {
  const result = await acceptInvitation({
    projectId: 1,
    accept: accept
  });
  
  if (result) {
    console.log("Invitation response recorded");
  }
};
```

### 3. Get Project Judges
```typescript
const { getProjectJudges } = useJudges();

const loadJudges = async () => {
  const judges = await getProjectJudges(1);
  console.log("Project judges:", judges);
};
```

## Testing

### Run Backend Tests
```bash
python -m pytest onchain_fastapi/tests/test_judges.py -v
```

### Run Frontend Tests
```bash
cd hub_nextjs
npm test -- __tests__/judges.test.tsx
```

### Run Integration Tests
```bash
python test_judge_system.py
python integration_test_judge_system.py
```

## Security

### Authentication
- All endpoints require valid JWT tokens
- Role-based access control implemented
- Only project creators and admins can assign judges

### Authorization
- Judges can only accept/decline their own invitations
- Project creators can manage judges for their projects
- Proper permission validation on all operations

### Data Validation
- Comprehensive input validation using Pydantic schemas
- SQL injection prevention with SQLAlchemy ORM
- XSS protection with proper data sanitization

## Error Handling

### Backend Errors
- 400: Bad Request (validation errors)
- 401: Unauthorized (missing/invalid token)
- 403: Forbidden (insufficient permissions)
- 404: Not Found (resource doesn't exist)
- 500: Internal Server Error

### Frontend Errors
- Network errors handled gracefully
- User-friendly error messages
- Automatic retry mechanisms
- Loading states for better UX

## Deployment

### Backend
1. Ensure database migrations are applied
2. Configure environment variables
3. Start FastAPI server
4. Verify API endpoints are accessible

### Frontend
1. Build the Next.js application
2. Configure API endpoints
3. Deploy to hosting platform
4. Test judge functionality

## Monitoring

### Metrics to Track
- Judge assignment success rate
- Invitation acceptance rate
- API response times
- Error rates by endpoint

### Logging
- All judge operations are logged
- Error tracking with stack traces
- Performance monitoring
- Security event logging

## Future Enhancements

### Planned Features
- Email notifications for invitations
- Judge scoring interface
- Bulk judge assignment
- Judge performance analytics
- Advanced permission system

### Technical Improvements
- Real-time notifications
- Caching for better performance
- Advanced search and filtering
- Mobile-responsive design

## Support

For issues or questions about the judge system:
1. Check the test results for common issues
2. Review the API documentation
3. Run the integration tests
4. Contact the development team

---

**Status**: ✅ Production Ready
**Last Updated**: 2024-01-15
**Version**: 1.0.0
