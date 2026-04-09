# Java/Spring Boot Microservice Code Generation Templates

Professional-grade code generation templates for building enterprise Java/Spring Boot microservices with full CRUD operations, testing, and best practices.

## Overview

This template collection provides a complete foundation for building scalable, maintainable Java microservices following Spring Boot and enterprise Java best practices.

### Features

- **Complete CRUD Operations**: Full create, read, update, delete functionality
- **Soft Delete Support**: Non-destructive delete with restore capability
- **Optimistic Locking**: Version control to prevent lost updates
- **Audit Trail**: Automatic tracking of created/updated timestamps and users
- **Validation**: Comprehensive input validation with custom error messages
- **Exception Handling**: Global exception handler with standardized error responses
- **Security**: Role-based access control with Spring Security
- **API Documentation**: OpenAPI 3.0/Swagger UI integration
- **Testing**: Unit and integration test templates with Mockito and MockMvc
- **Pagination**: Built-in pagination and sorting support
- **Caching**: Caffeine cache integration
- **Monitoring**: Actuator endpoints with Prometheus metrics
- **Database**: JPA/Hibernate with PostgreSQL support

## Template Files

### Entity Layer
1. **base-entity.java.template** - Base entity with audit fields, soft delete, optimistic locking
2. **entity.java.template** - JPA entity with annotations and lifecycle hooks

### Repository Layer
3. **repository.java.template** - Spring Data JPA repository with custom queries

### Service Layer
4. **service-interface.java.template** - Service contract defining business operations
5. **service-impl.java.template** - Service implementation with business logic

### Controller Layer
6. **controller.java.template** - REST controller with full CRUD endpoints

### DTO Layer
7. **dto.java.template** - Request DTO with validation annotations
8. **dto-response.java.template** - Response DTO for API responses
9. **mapper.java.template** - MapStruct mapper for entity-DTO conversion

### Exception Handling
10. **custom-exceptions.java.template** - Custom exception classes
11. **error-response.java.template** - Standardized error response DTO
12. **exception-handler.java.template** - Global exception handler

### Testing
13. **service-test.java.template** - Unit tests for service layer
14. **controller-test.java.template** - Integration tests for REST endpoints

### Configuration
15. **application.yml.template** - Application configuration with profiles
16. **pom.xml.template** - Maven build configuration with dependencies

## Placeholders

Replace these placeholders when generating code:

### Package and Naming
- `{{PACKAGE_NAME}}` - Base package name (e.g., `com.company.service`)
- `{{ENTITY_NAME}}` - Entity class name (e.g., `Product`, `Order`, `Customer`)
- `{{TABLE_NAME}}` - Database table name (e.g., `products`, `orders`)
- `{{REPOSITORY_NAME}}` - Repository interface name (e.g., `ProductRepository`)
- `{{SERVICE_NAME}}` - Service interface name (e.g., `ProductService`)
- `{{CONTROLLER_NAME}}` - Controller class name (e.g., `ProductController`)
- `{{DTO_NAME}}` - DTO base name (e.g., `Product` for `ProductRequest`/`ProductResponse`)
- `{{TEST_CLASS}}` - Test class name (e.g., `ProductServiceTest`)

### API Configuration
- `{{BASE_PATH}}` - API base path (e.g., `/api/v1/products`)
- `{{PORT}}` - Server port (e.g., `8080`, `8081`)

### Database Configuration
- `{{DB_HOST}}` - Database host (e.g., `localhost`, `db.company.com`)
- `{{DB_PORT}}` - Database port (e.g., `5432`)
- `{{DB_NAME}}` - Database name (e.g., `product_service`)
- `{{DB_USERNAME}}` - Database username
- `{{DB_PASSWORD}}` - Database password

### Maven Configuration
- `{{GROUP_ID}}` - Maven group ID (e.g., `com.company`)
- `{{ARTIFACT_ID}}` - Maven artifact ID (e.g., `product-service`)
- `{{SERVICE_NAME}}` - Service name (e.g., `Product Service`)
- `{{SERVICE_DESCRIPTION}}` - Service description

### Security
- `{{JWT_SECRET}}` - JWT signing secret (generate secure random string)
- `{{DOMAIN}}` - Production domain (e.g., `api.company.com`)

### Field Definitions
- `{{FIELDS}}` - Entity/DTO field definitions (see examples below)

## Usage Examples

### Example 1: Product Entity

```bash
# Replace placeholders
PACKAGE_NAME="com.company.ecommerce"
ENTITY_NAME="Product"
TABLE_NAME="products"
REPOSITORY_NAME="ProductRepository"
SERVICE_NAME="ProductService"
CONTROLLER_NAME="ProductController"
BASE_PATH="/api/v1/products"
PORT="8080"

# Field definitions for Product
FIELDS='
    @Column(name = "name", nullable = false, length = 255)
    @NotBlank(message = "Product name cannot be blank")
    @Size(min = 2, max = 255, message = "Name must be between 2 and 255 characters")
    private String name;

    @Column(name = "description", columnDefinition = "TEXT")
    @Size(max = 2000, message = "Description must not exceed 2000 characters")
    private String description;

    @Column(name = "price", precision = 19, scale = 2, nullable = false)
    @NotNull(message = "Price cannot be null")
    @DecimalMin(value = "0.01", message = "Price must be greater than 0")
    private BigDecimal price;

    @Column(name = "sku", nullable = false, unique = true, length = 100)
    @NotBlank(message = "SKU cannot be blank")
    private String sku;

    @Column(name = "quantity", nullable = false)
    @Min(value = 0, message = "Quantity cannot be negative")
    private Integer quantity;

    @Column(name = "status", nullable = false, length = 50)
    @Enumerated(EnumType.STRING)
    @NotNull(message = "Status cannot be null")
    private ProductStatus status;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id")
    private Category category;
'
```

### Example 2: Order Entity

```bash
# Replace placeholders
ENTITY_NAME="Order"
TABLE_NAME="orders"
REPOSITORY_NAME="OrderRepository"
SERVICE_NAME="OrderService"
CONTROLLER_NAME="OrderController"
BASE_PATH="/api/v1/orders"

# Field definitions for Order
FIELDS='
    @Column(name = "order_number", nullable = false, unique = true, length = 50)
    @NotBlank(message = "Order number cannot be blank")
    private String orderNumber;

    @Column(name = "customer_email", nullable = false, length = 255)
    @Email(message = "Customer email must be valid")
    @NotBlank(message = "Customer email cannot be blank")
    private String customerEmail;

    @Column(name = "total_amount", precision = 19, scale = 2, nullable = false)
    @NotNull(message = "Total amount cannot be null")
    @DecimalMin(value = "0.00", message = "Total amount must be positive")
    private BigDecimal totalAmount;

    @Column(name = "status", nullable = false, length = 50)
    @Enumerated(EnumType.STRING)
    @NotNull(message = "Order status cannot be null")
    private OrderStatus status;

    @Column(name = "ordered_at", nullable = false)
    @NotNull(message = "Order date cannot be null")
    private LocalDateTime orderedAt;

    @Column(name = "shipped_at")
    private LocalDateTime shippedAt;

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<OrderItem> items = new ArrayList<>();
'
```

### Example 3: Customer Entity

```bash
# Replace placeholders
ENTITY_NAME="Customer"
TABLE_NAME="customers"
REPOSITORY_NAME="CustomerRepository"
SERVICE_NAME="CustomerService"
CONTROLLER_NAME="CustomerController"
BASE_PATH="/api/v1/customers"

# Field definitions for Customer
FIELDS='
    @Column(name = "first_name", nullable = false, length = 100)
    @NotBlank(message = "First name cannot be blank")
    @Size(min = 1, max = 100, message = "First name must be between 1 and 100 characters")
    private String firstName;

    @Column(name = "last_name", nullable = false, length = 100)
    @NotBlank(message = "Last name cannot be blank")
    @Size(min = 1, max = 100, message = "Last name must be between 1 and 100 characters")
    private String lastName;

    @Column(name = "email", nullable = false, unique = true, length = 255)
    @Email(message = "Email must be valid")
    @NotBlank(message = "Email cannot be blank")
    private String email;

    @Column(name = "phone", length = 20)
    @Pattern(regexp = "^\\+?[1-9]\\d{1,14}$", message = "Phone number must be valid E.164 format")
    private String phone;

    @Column(name = "date_of_birth")
    @Past(message = "Date of birth must be in the past")
    private LocalDate dateOfBirth;

    @Column(name = "loyalty_points", nullable = false)
    @Min(value = 0, message = "Loyalty points cannot be negative")
    private Integer loyaltyPoints = 0;

    @Column(name = "active", nullable = false)
    private Boolean active = true;

    @OneToMany(mappedBy = "customer", cascade = CascadeType.ALL)
    private List<Order> orders = new ArrayList<>();
'
```

## Project Structure

Generated code follows this structure:

```
src/
├── main/
│   ├── java/
│   │   └── {PACKAGE_NAME}/
│   │       ├── controller/
│   │       │   └── {ENTITY_NAME}Controller.java
│   │       ├── service/
│   │       │   ├── {ENTITY_NAME}Service.java
│   │       │   └── impl/
│   │       │       └── {ENTITY_NAME}ServiceImpl.java
│   │       ├── repository/
│   │       │   └── {ENTITY_NAME}Repository.java
│   │       ├── domain/
│   │       │   └── entity/
│   │       │       ├── base/
│   │       │       │   └── BaseEntity.java
│   │       │       └── {ENTITY_NAME}.java
│   │       ├── dto/
│   │       │   ├── {ENTITY_NAME}Request.java
│   │       │   └── {ENTITY_NAME}Response.java
│   │       ├── mapper/
│   │       │   └── {ENTITY_NAME}Mapper.java
│   │       └── exception/
│   │           ├── BusinessException.java
│   │           ├── EntityNotFoundException.java
│   │           ├── ErrorResponse.java
│   │           └── GlobalExceptionHandler.java
│   └── resources/
│       └── application.yml
├── test/
│   └── java/
│       └── {PACKAGE_NAME}/
│           ├── service/
│           │   └── {ENTITY_NAME}ServiceTest.java
│           └── controller/
│               └── {ENTITY_NAME}ControllerTest.java
└── pom.xml
```

## API Endpoints

Generated controllers provide these endpoints:

### CRUD Operations
- `POST /api/v1/{resource}` - Create new entity
- `GET /api/v1/{resource}/{id}` - Get entity by ID
- `GET /api/v1/{resource}` - Get all entities (paginated)
- `PUT /api/v1/{resource}/{id}` - Update entity (full)
- `PATCH /api/v1/{resource}/{id}` - Update entity (partial)
- `DELETE /api/v1/{resource}/{id}` - Soft delete entity

### Additional Operations
- `POST /api/v1/{resource}/{id}/restore` - Restore soft-deleted entity
- `GET /api/v1/{resource}/{id}/exists` - Check if entity exists
- `GET /api/v1/{resource}/count` - Count active entities
- `GET /api/v1/{resource}/created-after?date={date}` - Find entities created after date
- `GET /api/v1/{resource}/updated-after?date={date}` - Find entities updated after date
- `POST /api/v1/{resource}/bulk` - Bulk create entities
- `DELETE /api/v1/{resource}/bulk` - Bulk delete entities

## Building and Running

### Build the project
```bash
mvn clean install
```

### Run tests
```bash
mvn test
```

### Run the application
```bash
mvn spring-boot:run
```

### Run with specific profile
```bash
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

### Build Docker image
```bash
mvn spring-boot:build-image
```

## Access Points

- **Application**: http://localhost:{PORT}/api
- **Swagger UI**: http://localhost:{PORT}/api/swagger-ui.html
- **OpenAPI Docs**: http://localhost:{PORT}/api/api-docs
- **Actuator Health**: http://localhost:{PORT}/api/actuator/health
- **Prometheus Metrics**: http://localhost:{PORT}/api/actuator/prometheus

## Best Practices

### Code Quality
- **Lombok**: Reduces boilerplate with @Data, @Builder, @Slf4j
- **MapStruct**: Type-safe bean mapping
- **Validation**: JSR-303/380 Bean Validation
- **Logging**: SLF4J with Logback
- **Exception Handling**: Global exception handler with standardized responses

### Database
- **Soft Delete**: Non-destructive deletion with restore capability
- **Optimistic Locking**: Version field prevents lost updates
- **Auditing**: Automatic created/updated timestamps and users
- **Connection Pooling**: HikariCP for optimal performance
- **Flyway**: Database migration management

### Security
- **JWT Authentication**: Token-based authentication
- **Role-based Access**: Method-level security with @PreAuthorize
- **CORS**: Configurable cross-origin resource sharing
- **Password Encoding**: BCrypt password hashing

### Performance
- **Pagination**: All list endpoints support pagination
- **Caching**: Caffeine cache for frequently accessed data
- **Lazy Loading**: Fetch strategies for relationships
- **Batch Operations**: Bulk insert/update/delete support
- **Connection Pool**: Optimized database connection management

### Testing
- **Unit Tests**: Service layer with Mockito mocks
- **Integration Tests**: Controller layer with MockMvc
- **Test Containers**: PostgreSQL test containers for integration tests
- **Code Coverage**: JaCoCo for test coverage reporting (70% minimum)
- **AssertJ**: Fluent assertions for better test readability

## Customization

### Adding Custom Business Logic

1. **Service Layer**: Add methods to service interface and implementation
2. **Repository Layer**: Add custom query methods
3. **Controller Layer**: Add new endpoints
4. **Validation**: Add custom validators in request DTOs
5. **Exception Handling**: Add custom exceptions and handlers

### Example: Custom Query

```java
// Repository
@Query("SELECT e FROM Product e WHERE e.price BETWEEN :minPrice AND :maxPrice AND e.deleted = false")
Page<Product> findByPriceRange(@Param("minPrice") BigDecimal minPrice, 
                                @Param("maxPrice") BigDecimal maxPrice, 
                                Pageable pageable);

// Service Interface
Page<ProductResponse> findByPriceRange(BigDecimal minPrice, BigDecimal maxPrice, Pageable pageable);

// Service Implementation
@Override
public Page<ProductResponse> findByPriceRange(BigDecimal minPrice, BigDecimal maxPrice, Pageable pageable) {
    return repository.findByPriceRange(minPrice, maxPrice, pageable)
            .map(mapper::toResponse);
}

// Controller
@GetMapping("/price-range")
public ResponseEntity<Page<ProductResponse>> findByPriceRange(
        @RequestParam BigDecimal minPrice,
        @RequestParam BigDecimal maxPrice,
        Pageable pageable) {
    return ResponseEntity.ok(service.findByPriceRange(minPrice, maxPrice, pageable));
}
```

## Dependencies

### Core
- Spring Boot 2.7.18
- Java 17
- PostgreSQL Driver
- Lombok 1.18.30
- MapStruct 1.5.5

### Web & API
- Spring Web
- Spring Validation
- SpringDoc OpenAPI 1.7.0

### Data & Persistence
- Spring Data JPA
- Hibernate
- Flyway
- HikariCP

### Security
- Spring Security
- JJWT 0.11.5

### Caching & Performance
- Caffeine 3.1.8
- Bucket4j 8.7.0 (rate limiting)

### Testing
- JUnit 5
- Mockito
- AssertJ
- Spring Test
- TestContainers 1.19.3

### Monitoring
- Spring Actuator
- Micrometer Prometheus

### Utilities
- Apache Commons Lang3 3.14.0
- Apache Commons Collections4 4.4
- Google Guava 33.0.0

## License

These templates are provided as-is for use in your projects. Customize as needed.

## Support

For questions or issues, consult:
- Spring Boot Documentation: https://spring.io/projects/spring-boot
- Spring Data JPA: https://spring.io/projects/spring-data-jpa
- MapStruct: https://mapstruct.org/
- Lombok: https://projectlombok.org/
