
# הוראות התקנה למערכת המיקרו-שירותים

## דרישות מוקדמות
- חשבון AWS פעיל
- יצירת IAM Roles: `PipelineRole`, `DeployRole`
- סביבת Cloud9 פעילה
- פתיחת פורטים 80, 8080, 8081 ב-Security Group
- רפוזיטוריז ב-CodeCommit: `microservices`, `deployment`

## שלב 1: שחזור קוד
1. העלה את תיקיות `microservices/` ו-`deployment/` ל-Cloud9.
2. ודא שמבנה התיקיות תקין כפי שתואר.

## שלב 2: בניית והעלאת Docker Images
1. בנה את התמונות מתוך `microservices/customer` ו-`employee`.
2. התחבר ל-ECR (**קוד 1**).
3. תייג את התמונות (**קוד 2**).
4. שלח את התמונות ל-ECR (**קוד 3**).

## שלב 3: רישום Task Definitions
1. עדכן את הקבצים `taskdef-*.json` והחלף `<IMAGE1_NAME>`, `<ACCOUNT-ID>`, `<RDS-ENDPOINT>`.
2. רישום באמצעות:
```bash
aws ecs register-task-definition --cli-input-json file://deployment/taskdef-customer.json
aws ecs register-task-definition --cli-input-json file://deployment/taskdef-employee.json
```

## שלב 4: יצירת שירותים
1. ערוך את קבצי `create-*.json` עם ה-ARNs וה-IDs הרלוונטיים.
2. צור שירותים:
```bash
aws ecs create-service --cli-input-json file://deployment/create-customer-microservice-tg-two.json
aws ecs create-service --cli-input-json file://deployment/create-employee-microservice-tg-two.json
```

## שלב 5: יצירת CodeDeploy ו-Pipeline
1. צור אפליקציה ודפלוימנט גרופ ב-CodeDeploy.
2. צור Pipeline עם CodeCommit + ECR והשתמש ב-`IMAGE1_NAME`.

## שלב 6: בדיקת המערכת
1. גש ל-ALB ובדוק שהשירותים פועלים כראוי.

## שלב 7: עדכון והפעלת Pipeline
- בצע שינוי, בנה Docker Image מחדש, שלח ל-ECR והPipeline ירוץ אוטומטית.

---

## קטעי קוד

### קוד 1 – התחברות ל-ECR
```bash
account_id=$(aws sts get-caller-identity --query "Account" --output text)
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $account_id.dkr.ecr.us-east-1.amazonaws.com
```

### קוד 2 – תיוג תמונות
```bash
docker tag customer:latest $account_id.dkr.ecr.us-east-1.amazonaws.com/customer:latest
docker tag employee:latest $account_id.dkr.ecr.us-east-1.amazonaws.com/employee:latest
```

### קוד 3 – שליחת תמונות ל-ECR
```bash
docker push $account_id.dkr.ecr.us-east-1.amazonaws.com/customer:latest
docker push $account_id.dkr.ecr.us-east-1.amazonaws.com/employee:latest
```
