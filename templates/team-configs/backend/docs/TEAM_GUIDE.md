# Backend Team Guide

## Overview

Welcome to the backend team! This guide covers our coding standards, testing strategy, API design guidelines, and best practices for building and maintaining Java/Spring Boot microservices.

## Table of Contents

1. [Technology Stack](#technology-stack)
2. [Project Structure](#project-structure)
3. [Coding Standards](#coding-standards)
4. [Testing Strategy](#testing-strategy)
5. [API Design Guidelines](#api-design-guidelines)
6. [Database Guidelines](#database-guidelines)
7. [Error Handling](#error-handling)
8. [Logging](#logging)
9. [Security Best Practices](#security-best-practices)
10. [Performance Optimization](#performance-optimization)
11. [Development Workflow](#development-workflow)
12. [Resources](#resources)

## Technology Stack

### Core Technologies

- **Java 17**: LTS version with modern language features
- **Spring Boot 3.2+**: Application framework
- **Spring Data JPA**: Database access layer
- **PostgreSQL**: Primary relational database
- **Redis**: Caching and session management
- **Apache Kafka**: Event streaming and messaging
- **Maven**: Build and dependency management

### Libraries & Frameworks

- **Hibernate**: ORM framework
- **MapStruct**: Object mapping
- **Lombok**: Boilerplate reduction
- **Jackson**: JSON serialization
- **Spring Security**: Authentication and authorization
- **SpringDoc OpenAPI**: API documentation
- **Micrometer**: Metrics and observability
- **JUnit 5**: Testing framework
- **Mockito**: Mocking framework
- **Testcontainers**: Integration testing
- **REST Assured**: API testing

## Project Structure

### Standard Maven Project Layout

```
src/
├── main/
│   ├── java/
│   │   └── com/polybase/[service]/
│   │       ├── config/           # Configuration classes
│   │       ├── controller/       # REST controllers
│   │       ├── dto/              # Data Transfer Objects
│   │       ├── entity/           # JPA entities
│   │       ├── repository/       # Spring Data repositories
│   │       ├── service/          # Business logic
│   │       │   ├── impl/         # Service implementations
│   │       │   └── mapper/       # DTO/Entity mappers
│   │       ├── exception/        # Custom exceptions
│   │       ├── security/         # Security configuration
│   │       ├── event/            # Event publishers/listeners
│   │       └── util/             # Utility classes
│   └── resources/
│       ├── application.yml       # Application configuration
│       ├── application-dev.yml   # Development config
│       ├── application-prod.yml  # Production config
│       └── db/migration/         # Database migrations
└── test/
    ├── java/                     # Unit and integration tests
    └── resources/                # Test resources
```

### Package Organization

- **One class per file**
- **Group by feature/domain** (not by layer)
- **Keep packages focused** (high cohesion)
- **Minimize inter-package dependencies**

Example feature-based structure:

```
com.polybase.order/
├── order/
│   ├── OrderController.java
│   ├── OrderService.java
│   ├── OrderRepository.java
│   ├── Order.java
│   └── OrderDto.java
├── orderitem/
│   ├── OrderItemService.java
│   ├── OrderItemRepository.java
│   └── OrderItem.java
└── pricing/
    ├── PricingService.java
    └── PriceCalculator.java
```

## Coding Standards

### Java Style Guide

We follow the [Google Java Style Guide](https://google.github.io/styleguide/javaguide.html) with minor modifications:

#### Naming Conventions

- **Classes**: PascalCase (e.g., `OrderService`, `UserRepository`)
- **Interfaces**: PascalCase, no "I" prefix (e.g., `OrderService`, not `IOrderService`)
- **Methods**: camelCase, verb phrases (e.g., `calculateTotal`, `findById`)
- **Variables**: camelCase, descriptive names (e.g., `userProfile`, `totalAmount`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `MAX_RETRY_ATTEMPTS`, `DEFAULT_TIMEOUT`)
- **Packages**: lowercase, singular nouns (e.g., `com.polybase.order`)

#### Code Organization

**Class Member Order:**

1. Static fields
2. Instance fields
3. Constructors
4. Static methods
5. Instance methods
6. Inner classes

**Method Size:**

- Keep methods short (ideally <20 lines)
- Extract complex logic into private methods
- One level of abstraction per method

#### Spring Boot Annotations

```java
@RestController
@RequestMapping("/api/v1/orders")
@RequiredArgsConstructor  // Lombok constructor injection
@Validated
public class OrderController {
    
    private final OrderService orderService;
    
    @GetMapping("/{id}")
    @Operation(summary = "Get order by ID")
    public ResponseEntity<OrderDto> getOrder(@PathVariable Long id) {
        return ResponseEntity.ok(orderService.findById(id));
    }
}
```

**Service Classes:**

```java
@Service
@RequiredArgsConstructor
@Slf4j  // Lombok logging
public class OrderServiceImpl implements OrderService {
    
    private final OrderRepository orderRepository;
    private final PaymentClient paymentClient;
    
    @Transactional(readOnly = true)
    public OrderDto findById(Long id) {
        return orderRepository.findById(id)
            .map(orderMapper::toDto)
            .orElseThrow(() -> new OrderNotFoundException(id));
    }
    
    @Transactional
    public OrderDto createOrder(CreateOrderRequest request) {
        // Implementation
    }
}
```

### Dependency Injection

**Always use constructor injection** (preferred by Spring team):

```java
// Good: Constructor injection
@Service
@RequiredArgsConstructor
public class OrderService {
    private final OrderRepository orderRepository;
    private final PaymentService paymentService;
}

// Avoid: Field injection
@Service
public class OrderService {
    @Autowired
    private OrderRepository orderRepository;  // Don't do this
}
```

### Lombok Usage

Appropriate Lombok annotations:

- `@RequiredArgsConstructor`: Constructor injection
- `@Slf4j`: Logging
- `@Data`: DTOs (use sparingly)
- `@Builder`: Complex object construction
- `@Value`: Immutable objects

Avoid: `@Data` on entities (can cause issues with JPA)

## Testing Strategy

### Test Pyramid

```
        /\        E2E Tests (5%)
       /  \
      /____\      Integration Tests (25%)
     /      \
    /________\    Unit Tests (70%)
```

### Unit Tests

**Characteristics:**
- Fast (<100ms per test)
- Isolated (mock external dependencies)
- Focused (test one behavior)
- Repeatable (same result every time)

**Example:**

```java
@ExtendWith(MockitoExtension.class)
class OrderServiceTest {
    
    @Mock
    private OrderRepository orderRepository;
    
    @Mock
    private PaymentService paymentService;
    
    @InjectMocks
    private OrderServiceImpl orderService;
    
    @Test
    @DisplayName("Should create order and process payment successfully")
    void shouldCreateOrderAndProcessPayment() {
        // Given
        CreateOrderRequest request = CreateOrderRequest.builder()
            .userId(1L)
            .items(List.of(createOrderItem()))
            .build();
        
        Order savedOrder = createOrder();
        when(orderRepository.save(any(Order.class))).thenReturn(savedOrder);
        when(paymentService.processPayment(any())).thenReturn(createPaymentResult());
        
        // When
        OrderDto result = orderService.createOrder(request);
        
        // Then
        assertThat(result).isNotNull();
        assertThat(result.getId()).isEqualTo(savedOrder.getId());
        assertThat(result.getStatus()).isEqualTo(OrderStatus.CONFIRMED);
        
        verify(orderRepository).save(any(Order.class));
        verify(paymentService).processPayment(any());
    }
    
    @Test
    @DisplayName("Should throw exception when payment fails")
    void shouldThrowExceptionWhenPaymentFails() {
        // Given
        CreateOrderRequest request = createOrderRequest();
        when(paymentService.processPayment(any()))
            .thenThrow(new PaymentFailedException("Insufficient funds"));
        
        // When/Then
        assertThatThrownBy(() -> orderService.createOrder(request))
            .isInstanceOf(PaymentFailedException.class)
            .hasMessage("Insufficient funds");
        
        verify(orderRepository, never()).save(any());
    }
}
```

### Integration Tests

**Characteristics:**
- Test multiple components together
- Use real database (Testcontainers)
- Test actual HTTP requests
- Slower than unit tests

**Example:**

```java
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
@Testcontainers
class OrderControllerIntegrationTest {
    
    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15")
        .withDatabaseName("testdb");
    
    @Autowired
    private TestRestTemplate restTemplate;
    
    @Autowired
    private OrderRepository orderRepository;
    
    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }
    
    @Test
    void shouldCreateOrderEndToEnd() {
        // Given
        CreateOrderRequest request = CreateOrderRequest.builder()
            .userId(1L)
            .items(List.of(createOrderItem()))
            .build();
        
        // When
        ResponseEntity<OrderDto> response = restTemplate.postForEntity(
            "/api/v1/orders",
            request,
            OrderDto.class
        );
        
        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getId()).isNotNull();
        
        // Verify database state
        Optional<Order> savedOrder = orderRepository.findById(response.getBody().getId());
        assertThat(savedOrder).isPresent();
        assertThat(savedOrder.get().getStatus()).isEqualTo(OrderStatus.CONFIRMED);
    }
}
```

### Test Naming Conventions

**Use descriptive names that explain the scenario:**

```java
// Good
@Test
void shouldReturnOrderWhenValidIdProvided() { }

@Test
void shouldThrowOrderNotFoundExceptionWhenInvalidId() { }

@Test
void shouldCalculateTotalWithTaxFor_US_Orders() { }

// Avoid
@Test
void testGetOrder() { }

@Test
void test1() { }
```

### Test Organization (AAA Pattern)

```java
@Test
void shouldApplyDiscountToEligibleOrders() {
    // Arrange (Given)
    Order order = Order.builder()
        .total(new BigDecimal("100.00"))
        .customerId(123L)
        .build();
    when(customerService.isVip(123L)).thenReturn(true);
    
    // Act (When)
    BigDecimal finalTotal = orderService.applyDiscount(order);
    
    // Assert (Then)
    assertThat(finalTotal).isEqualByComparingTo("90.00");
}
```

### Coverage Requirements

- **Overall coverage: ≥70%**
- **New code: ≥80%**
- **Critical paths: ≥90%** (auth, payment, data integrity)

Run coverage report:

```bash
mvn jacoco:report
```

View report: `target/site/jacoco/index.html`

## API Design Guidelines

### RESTful Principles

#### Resource Naming

- Use **plural nouns** for collections: `/api/v1/orders`, `/api/v1/users`
- Use **hierarchical structure** for relationships: `/api/v1/orders/{orderId}/items`
- Use **kebab-case** for multi-word resources: `/api/v1/order-items`

#### HTTP Methods

- `GET`: Retrieve resource(s)
- `POST`: Create new resource
- `PUT`: Full update (replace entire resource)
- `PATCH`: Partial update
- `DELETE`: Remove resource

#### Status Codes

**Success:**
- `200 OK`: Successful GET, PUT, PATCH, DELETE
- `201 Created`: Successful POST
- `204 No Content`: Successful DELETE with no body

**Client Errors:**
- `400 Bad Request`: Invalid input
- `401 Unauthorized`: Missing/invalid authentication
- `403 Forbidden`: Authenticated but not authorized
- `404 Not Found`: Resource doesn't exist
- `409 Conflict`: Resource state conflict
- `422 Unprocessable Entity`: Validation failed

**Server Errors:**
- `500 Internal Server Error`: Unexpected server error
- `503 Service Unavailable`: Service temporarily down

### Request/Response Format

**Request:**

```java
@PostMapping("/api/v1/orders")
public ResponseEntity<OrderDto> createOrder(
    @Valid @RequestBody CreateOrderRequest request) {
    
    OrderDto order = orderService.createOrder(request);
    
    return ResponseEntity
        .created(URI.create("/api/v1/orders/" + order.getId()))
        .body(order);
}
```

**Response DTOs:**

```java
@Data
@Builder
public class OrderDto {
    private Long id;
    private Long userId;
    private OrderStatus status;
    private BigDecimal total;
    private LocalDateTime createdAt;
    private List<OrderItemDto> items;
    
    @Schema(description = "HATEOAS links")
    private Map<String, String> links;
}
```

### Validation

**Use Bean Validation:**

```java
@Data
public class CreateOrderRequest {
    
    @NotNull(message = "User ID is required")
    private Long userId;
    
    @NotEmpty(message = "Order must contain at least one item")
    @Valid
    private List<OrderItemRequest> items;
    
    @NotNull
    @DecimalMin(value = "0.0", inclusive = false)
    private BigDecimal total;
    
    @Email(message = "Invalid email format")
    private String customerEmail;
    
    @Pattern(regexp = "^\\+?[1-9]\\d{1,14}$", message = "Invalid phone number")
    private String phoneNumber;
}
```

### Pagination

**Use standardized pagination:**

```java
@GetMapping("/api/v1/orders")
public ResponseEntity<Page<OrderDto>> listOrders(
    @RequestParam(defaultValue = "0") int page,
    @RequestParam(defaultValue = "20") int size,
    @RequestParam(defaultValue = "createdAt,desc") String sort) {
    
    Pageable pageable = PageRequest.of(page, size, Sort.by(sort));
    Page<OrderDto> orders = orderService.findAll(pageable);
    
    return ResponseEntity.ok(orders);
}
```

**Response:**

```json
{
  "content": [...],
  "pageable": {
    "page": 0,
    "size": 20,
    "sort": "createdAt,desc"
  },
  "totalElements": 150,
  "totalPages": 8,
  "last": false
}
```

### Filtering and Sorting

```java
@GetMapping("/api/v1/orders")
public ResponseEntity<Page<OrderDto>> searchOrders(
    @RequestParam(required = false) OrderStatus status,
    @RequestParam(required = false) Long userId,
    @RequestParam(required = false) @DateTimeFormat(iso = ISO.DATE) LocalDate from,
    @RequestParam(required = false) @DateTimeFormat(iso = ISO.DATE) LocalDate to,
    Pageable pageable) {
    
    OrderSearchCriteria criteria = OrderSearchCriteria.builder()
        .status(status)
        .userId(userId)
        .dateFrom(from)
        .dateTo(to)
        .build();
    
    return ResponseEntity.ok(orderService.search(criteria, pageable));
}
```

### API Versioning

**Use URL versioning:**

```java
@RestController
@RequestMapping("/api/v1/orders")  // Version in URL
public class OrderController {
    // v1 implementation
}

@RestController
@RequestMapping("/api/v2/orders")  // New version
public class OrderV2Controller {
    // v2 implementation with breaking changes
}
```

**Deprecation:**

```java
@Deprecated(since = "2.0", forRemoval = true)
@GetMapping("/api/v1/old-endpoint")
@Operation(
    summary = "Legacy endpoint",
    deprecated = true,
    description = "Deprecated. Use /api/v2/new-endpoint instead. Will be removed in v3.0"
)
public ResponseEntity<?> oldEndpoint() {
    // Implementation
}
```

## Database Guidelines

### Entity Design

```java
@Entity
@Table(
    name = "orders",
    indexes = {
        @Index(name = "idx_user_created", columnList = "user_id, created_at"),
        @Index(name = "idx_status", columnList = "status")
    }
)
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Order extends BaseEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "user_id", nullable = false)
    private Long userId;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private OrderStatus status;
    
    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal total;
    
    @OneToMany(
        mappedBy = "order",
        cascade = CascadeType.ALL,
        orphanRemoval = true,
        fetch = FetchType.LAZY
    )
    private List<OrderItem> items = new ArrayList<>();
    
    @Version
    private Long version;  // Optimistic locking
    
    // Helper methods
    public void addItem(OrderItem item) {
        items.add(item);
        item.setOrder(this);
    }
}
```

### Repository Pattern

```java
@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {
    
    @Query("SELECT o FROM Order o WHERE o.userId = :userId AND o.status = :status")
    Page<Order> findByUserIdAndStatus(
        @Param("userId") Long userId,
        @Param("status") OrderStatus status,
        Pageable pageable
    );
    
    @Query("SELECT o FROM Order o LEFT JOIN FETCH o.items WHERE o.id = :id")
    Optional<Order> findByIdWithItems(@Param("id") Long id);
    
    @Modifying
    @Query("UPDATE Order o SET o.status = :status WHERE o.id = :id")
    int updateStatus(@Param("id") Long id, @Param("status") OrderStatus status);
}
```

### Database Migrations

Use **Flyway** for versioned database migrations:

**File naming:** `V{version}__{description}.sql`

Example: `V1__create_orders_table.sql`

```sql
-- V1__create_orders_table.sql
CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    status VARCHAR(20) NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version BIGINT NOT NULL DEFAULT 0
);

CREATE INDEX idx_user_created ON orders(user_id, created_at);
CREATE INDEX idx_status ON orders(status);
```

### Transaction Management

```java
@Service
@RequiredArgsConstructor
public class OrderService {
    
    @Transactional(readOnly = true)  // Read-only optimization
    public OrderDto findById(Long id) {
        // Read operation
    }
    
    @Transactional  // Default: READ_COMMITTED, propagation REQUIRED
    public OrderDto createOrder(CreateOrderRequest request) {
        // Write operation
    }
    
    @Transactional(
        isolation = Isolation.SERIALIZABLE,  // Highest isolation
        timeout = 30  // 30 second timeout
    )
    public void processHighValueOrder(CreateOrderRequest request) {
        // Critical operation requiring serializable isolation
    }
}
```

## Error Handling

### Exception Hierarchy

```java
public class BusinessException extends RuntimeException {
    private final String errorCode;
    
    public BusinessException(String errorCode, String message) {
        super(message);
        this.errorCode = errorCode;
    }
}

public class OrderNotFoundException extends BusinessException {
    public OrderNotFoundException(Long orderId) {
        super("ORDER_NOT_FOUND", "Order not found: " + orderId);
    }
}

public class PaymentFailedException extends BusinessException {
    public PaymentFailedException(String reason) {
        super("PAYMENT_FAILED", "Payment failed: " + reason);
    }
}
```

### Global Exception Handler

```java
@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {
    
    @ExceptionHandler(OrderNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleOrderNotFound(OrderNotFoundException ex) {
        log.warn("Order not found: {}", ex.getMessage());
        
        ErrorResponse error = ErrorResponse.builder()
            .timestamp(LocalDateTime.now())
            .status(HttpStatus.NOT_FOUND.value())
            .error("Not Found")
            .message(ex.getMessage())
            .code(ex.getErrorCode())
            .build();
        
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
    }
    
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidationErrors(
        MethodArgumentNotValidException ex) {
        
        Map<String, String> fieldErrors = ex.getBindingResult()
            .getFieldErrors()
            .stream()
            .collect(Collectors.toMap(
                FieldError::getField,
                FieldError::getDefaultMessage
            ));
        
        ErrorResponse error = ErrorResponse.builder()
            .timestamp(LocalDateTime.now())
            .status(HttpStatus.BAD_REQUEST.value())
            .error("Validation Failed")
            .message("Input validation failed")
            .code("VALIDATION_ERROR")
            .fieldErrors(fieldErrors)
            .build();
        
        return ResponseEntity.badRequest().body(error);
    }
    
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGenericException(Exception ex) {
        log.error("Unexpected error", ex);
        
        ErrorResponse error = ErrorResponse.builder()
            .timestamp(LocalDateTime.now())
            .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
            .error("Internal Server Error")
            .message("An unexpected error occurred")
            .code("INTERNAL_ERROR")
            .build();
        
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
    }
}
```

## Logging

### Logging Levels

- **ERROR**: System errors requiring immediate attention
- **WARN**: Potential issues, degraded functionality
- **INFO**: Important business events
- **DEBUG**: Detailed diagnostic information
- **TRACE**: Very detailed diagnostic information

### Logging Best Practices

```java
@Service
@Slf4j
public class OrderService {
    
    public OrderDto createOrder(CreateOrderRequest request) {
        log.info("Creating order for user: {}", request.getUserId());
        log.debug("Order details: {}", request);
        
        try {
            Order order = processOrder(request);
            log.info("Order created successfully: orderId={}, userId={}, total={}",
                order.getId(), order.getUserId(), order.getTotal());
            return orderMapper.toDto(order);
            
        } catch (PaymentFailedException e) {
            log.error("Payment failed for user: {}, reason: {}",
                request.getUserId(), e.getMessage(), e);
            throw e;
            
        } catch (Exception e) {
            log.error("Unexpected error creating order for user: {}",
                request.getUserId(), e);
            throw new OrderCreationException("Failed to create order", e);
        }
    }
}
```

### Structured Logging

Use MDC (Mapped Diagnostic Context) for correlation:

```java
@Component
public class CorrelationIdFilter extends OncePerRequestFilter {
    
    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                  HttpServletResponse response,
                                  FilterChain filterChain) throws ServletException, IOException {
        
        String correlationId = request.getHeader("X-Correlation-ID");
        if (correlationId == null) {
            correlationId = UUID.randomUUID().toString();
        }
        
        MDC.put("correlationId", correlationId);
        MDC.put("userId", extractUserId(request));
        
        try {
            response.addHeader("X-Correlation-ID", correlationId);
            filterChain.doFilter(request, response);
        } finally {
            MDC.clear();
        }
    }
}
```

**Logback configuration:**

```xml
<pattern>%d{ISO8601} [%thread] %-5level %logger{36} [correlationId=%X{correlationId}, userId=%X{userId}] - %msg%n</pattern>
```

## Security Best Practices

### Authentication

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf().disable()  // Use tokens instead
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/v1/public/**").permitAll()
                .requestMatchers("/api/v1/admin/**").hasRole("ADMIN")
                .anyRequest().authenticated()
            )
            .oauth2ResourceServer(oauth2 -> oauth2.jwt());
        
        return http.build();
    }
}
```

### Input Validation

```java
@PostMapping("/api/v1/orders")
public ResponseEntity<OrderDto> createOrder(
    @Valid @RequestBody CreateOrderRequest request,
    @AuthenticationPrincipal Jwt jwt) {
    
    // Additional business validation
    if (request.getTotal().compareTo(BigDecimal.ZERO) <= 0) {
        throw new InvalidOrderException("Total must be positive");
    }
    
    // Authorization check
    Long userId = Long.parseLong(jwt.getSubject());
    if (!userId.equals(request.getUserId())) {
        throw new ForbiddenException("Cannot create order for another user");
    }
    
    return ResponseEntity.ok(orderService.createOrder(request));
}
```

### Sensitive Data Handling

```java
@Entity
public class User {
    
    @Column(nullable = false)
    @Convert(converter = EncryptedStringConverter.class)  // Encrypt at rest
    private String socialSecurityNumber;
    
    @Column(nullable = false)
    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)  // Never serialize
    private String password;
}
```

## Performance Optimization

### Caching

```java
@Service
@CacheConfig(cacheNames = "orders")
public class OrderService {
    
    @Cacheable(key = "#id")
    public OrderDto findById(Long id) {
        // Cached after first call
    }
    
    @CachePut(key = "#result.id")
    public OrderDto updateOrder(Long id, UpdateOrderRequest request) {
        // Updates cache
    }
    
    @CacheEvict(key = "#id")
    public void deleteOrder(Long id) {
        // Removes from cache
    }
}
```

### Async Processing

```java
@Service
public class NotificationService {
    
    @Async("taskExecutor")
    public CompletableFuture<Void> sendOrderConfirmation(Order order) {
        // Runs asynchronously
        emailService.send(order.getCustomerEmail(), buildEmail(order));
        return CompletableFuture.completedFuture(null);
    }
}
```

### Query Optimization

```java
// Bad: N+1 query problem
List<Order> orders = orderRepository.findAll();
orders.forEach(order -> {
    order.getItems().size();  // Triggers separate query for each order
});

// Good: Fetch join
@Query("SELECT o FROM Order o LEFT JOIN FETCH o.items WHERE o.userId = :userId")
List<Order> findByUserIdWithItems(@Param("userId") Long userId);
```

## Development Workflow

### Local Development Setup

```bash
# Clone repository
git clone https://github.com/polybase-poc/order-service.git

# Build project
mvn clean install

# Run tests
mvn test

# Start local dependencies
docker-compose up -d postgres redis kafka

# Run application
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

### Git Workflow

1. **Create branch**: `git checkout -b feature/order/add-bulk-processing`
2. **Make changes** and commit regularly
3. **Push branch**: `git push -u origin feature/order/add-bulk-processing`
4. **Create PR** via GitHub
5. **Address review feedback**
6. **Merge** after approval

See [Branch Naming](../.claude/rules/branch-naming.md) and [Commit Template](../.claude/rules/commit-template.md) for details.

## Resources

### Documentation

- [Spring Boot Documentation](https://docs.spring.io/spring-boot/docs/current/reference/html/)
- [Spring Data JPA](https://docs.spring.io/spring-data/jpa/docs/current/reference/html/)
- [Spring Security](https://docs.spring.io/spring-security/reference/)
- [Google Java Style Guide](https://google.github.io/styleguide/javaguide.html)

### Internal Resources

- [API Documentation](https://api.polybase.dev/docs)
- [Architecture Decision Records](https://github.com/polybase-poc/architecture)
- [Team Slack Channel](https://polybase.slack.com/archives/backend-team)
- [On-Call Runbook](https://wiki.polybase.dev/runbooks/backend)

### Training

- Java 17 new features workshop
- Spring Boot 3 migration guide
- Kafka event-driven architecture patterns
- Database performance optimization

### Support

- **Technical questions**: #backend-help Slack channel
- **Architecture decisions**: #architecture Slack channel
- **On-call support**: PagerDuty rotation
- **Office hours**: Thursdays 2-3 PM EST

## Questions?

Reach out in #backend-team on Slack or ping @backend-leads.

Welcome to the team!
