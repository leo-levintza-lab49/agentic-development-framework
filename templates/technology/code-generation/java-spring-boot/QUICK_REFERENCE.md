# Java/Spring Boot Templates - Quick Reference Card

## Template Files (18)

| Template | Purpose | Size |
|----------|---------|------|
| `base-entity.java.template` | Base entity with audit fields | 3.3K |
| `entity.java.template` | JPA entity class | 2.7K |
| `repository.java.template` | Spring Data repository | 4.7K |
| `service-interface.java.template` | Service contract | 5.2K |
| `service-impl.java.template` | Service implementation | 12K |
| `controller.java.template` | REST controller | 16K |
| `dto.java.template` | Request DTO | 2.9K |
| `dto-response.java.template` | Response DTO | 3.1K |
| `mapper.java.template` | MapStruct mapper | 4.7K |
| `custom-exceptions.java.template` | Exception classes | 5.4K |
| `error-response.java.template` | Error response DTO | 1.6K |
| `exception-handler.java.template` | Global exception handler | 11K |
| `configuration.java.template` | App configuration | 11K |
| `service-test.java.template` | Unit tests | 14K |
| `controller-test.java.template` | Integration tests | 16K |
| `pom.xml.template` | Maven build file | 17K |
| `application.yml.template` | Application config | 6.1K |
| `generate.sh` | Generation script | Executable |

## Essential Placeholders

### Required
- `{{PACKAGE_NAME}}` - Base package (e.g., `com.company.service`)
- `{{ENTITY_NAME}}` - Entity class name (e.g., `Product`)
- `{{TABLE_NAME}}` - Database table name (e.g., `products`)
- `{{FIELDS}}` - Entity field definitions

### Auto-Generated (from ENTITY_NAME)
- `{{REPOSITORY_NAME}}` - `{ENTITY_NAME}Repository`
- `{{SERVICE_NAME}}` - `{ENTITY_NAME}Service`
- `{{CONTROLLER_NAME}}` - `{ENTITY_NAME}Controller`
- `{{DTO_NAME}}` - `{ENTITY_NAME}` (for Request/Response)

### Configuration
- `{{BASE_PATH}}` - API path (e.g., `/api/v1/products`)
- `{{PORT}}` - Server port (default: `8080`)
- `{{DB_HOST}}`, `{{DB_PORT}}`, `{{DB_NAME}}` - Database config
- `{{GROUP_ID}}`, `{{ARTIFACT_ID}}` - Maven coordinates

## Quick Start (3 Steps)

### 1. Run Generator
```bash
./generate.sh
```

### 2. Customize Fields
Edit generated entity and DTO files to add your domain-specific fields.

### 3. Build & Run
```bash
cd generated/{artifact-id}
mvn spring-boot:run
```

## Field Definition Examples

### String Field
```java
@Column(name = "name", nullable = false, length = 255)
@NotBlank(message = "Name cannot be blank")
@Size(min = 2, max = 255)
private String name;
```

### Decimal Field
```java
@Column(name = "price", precision = 19, scale = 2)
@NotNull
@DecimalMin(value = "0.01")
private BigDecimal price;
```

### Enum Field
```java
@Column(name = "status", nullable = false, length = 50)
@Enumerated(EnumType.STRING)
@NotNull
private Status status;
```

### Date Field
```java
@Column(name = "ordered_at")
@NotNull
private LocalDateTime orderedAt;
```

### Relationship (Many-to-One)
```java
@ManyToOne(fetch = FetchType.LAZY)
@JoinColumn(name = "category_id")
private Category category;
```

### Relationship (One-to-Many)
```java
@OneToMany(mappedBy = "order", cascade = CascadeType.ALL)
private List<OrderItem> items = new ArrayList<>();
```

## Generated Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/{resource}` | Create |
| GET | `/api/v1/{resource}/{id}` | Get by ID |
| GET | `/api/v1/{resource}` | List all (paginated) |
| PUT | `/api/v1/{resource}/{id}` | Full update |
| PATCH | `/api/v1/{resource}/{id}` | Partial update |
| DELETE | `/api/v1/{resource}/{id}` | Soft delete |
| POST | `/api/v1/{resource}/{id}/restore` | Restore deleted |
| GET | `/api/v1/{resource}/{id}/exists` | Check existence |
| GET | `/api/v1/{resource}/count` | Count active |
| POST | `/api/v1/{resource}/bulk` | Bulk create |
| DELETE | `/api/v1/{resource}/bulk` | Bulk delete |

## Common Maven Commands

```bash
# Build
mvn clean install

# Run tests
mvn test

# Run application
mvn spring-boot:run

# Run with profile
mvn spring-boot:run -Dspring-boot.run.profiles=dev

# Package JAR
mvn clean package

# Build Docker image
mvn spring-boot:build-image

# Skip tests
mvn clean install -DskipTests

# Code coverage
mvn clean test jacoco:report
```

## Access URLs

| Service | URL |
|---------|-----|
| Application | `http://localhost:{PORT}/api` |
| Swagger UI | `http://localhost:{PORT}/api/swagger-ui.html` |
| OpenAPI Docs | `http://localhost:{PORT}/api/api-docs` |
| Health Check | `http://localhost:{PORT}/api/actuator/health` |
| Metrics | `http://localhost:{PORT}/api/actuator/metrics` |
| Prometheus | `http://localhost:{PORT}/api/actuator/prometheus` |

## Key Features Included

- ✅ Full CRUD operations
- ✅ Soft delete with restore
- ✅ Optimistic locking
- ✅ Audit trail (created/updated by/at)
- ✅ Pagination and sorting
- ✅ Bulk operations
- ✅ Bean validation
- ✅ Exception handling
- ✅ Unit tests (Mockito)
- ✅ Integration tests (MockMvc)
- ✅ OpenAPI/Swagger documentation
- ✅ Security (JWT ready)
- ✅ Actuator health checks
- ✅ Prometheus metrics
- ✅ Caching (Caffeine)
- ✅ Database migration (Flyway)
- ✅ Connection pooling (HikariCP)

## Configuration Profiles

| Profile | Use Case | Database |
|---------|----------|----------|
| `dev` | Development | PostgreSQL (localhost) |
| `test` | Testing | H2 (in-memory) |
| `prod` | Production | PostgreSQL (configured) |

## Security Authorities

Each endpoint requires specific authorities:
- `{ENTITY_NAME}_CREATE` - Create operations
- `{ENTITY_NAME}_READ` - Read operations
- `{ENTITY_NAME}_UPDATE` - Update operations
- `{ENTITY_NAME}_DELETE` - Delete operations

Example: `@PreAuthorize("hasAuthority('Product_CREATE')")`

## Testing

### Run All Tests
```bash
mvn test
```

### Run Specific Test
```bash
mvn test -Dtest=ProductServiceTest
```

### Run Integration Tests Only
```bash
mvn verify -DskipUTs
```

### Check Coverage
```bash
mvn clean test jacoco:report
# View: target/site/jacoco/index.html
```

## Customization Checklist

After generation:
1. [ ] Review and customize entity fields
2. [ ] Update DTO validation rules
3. [ ] Add custom business logic to service
4. [ ] Add custom repository queries
5. [ ] Configure database credentials
6. [ ] Set JWT secret
7. [ ] Review security authorities
8. [ ] Add custom endpoints if needed
9. [ ] Update API documentation
10. [ ] Add integration tests for custom logic

## Common Issues & Solutions

### Issue: Port already in use
**Solution**: Change port in `application.yml` or use:
```bash
mvn spring-boot:run -Dspring-boot.run.arguments="--server.port=8081"
```

### Issue: Database connection failed
**Solution**: Check PostgreSQL is running and credentials in `application.yml`

### Issue: Lombok not working
**Solution**: Enable annotation processing in your IDE

### Issue: MapStruct not generating mappers
**Solution**: Run `mvn clean compile` to trigger annotation processing

### Issue: Tests failing
**Solution**: Ensure H2 database is available for tests or use TestContainers

## Resources

- Spring Boot: https://spring.io/projects/spring-boot
- Spring Data JPA: https://spring.io/projects/spring-data-jpa
- MapStruct: https://mapstruct.org/
- Lombok: https://projectlombok.org/
- OpenAPI: https://springdoc.org/

---

**Quick Help**: `./generate.sh` to start | See `README.md` for detailed docs
