---
name: World-Class Test-Driven Development (TDD)
description: A practical guide to the best Test-Driven Development practices, testing strategies, and CI/CD integration adopted by Senior and Staff-level software engineers to build bulletproof systems.
---

# World-Class Test-Driven Development (TDD)

This skill outlines the **"Senior-level" approach to software testing**. For world-class engineers, testing isn't an afterthought done to "please the coverage tool"; it's a design tool to shape architecture, enforce contracts, and allow fearless refactoring.

Apply the following methodologies when writing code or creating CI/CD pipelines.

---

## 1. The Real Meaning of TDD (Red-Green-Refactor)

TDD is about confidence and design, not just writing tests first.

*   **Red**: Write a *failing* test. This proves the test is actually testing something and forces you to design the API/Method from the caller's perspective before implementing it.
*   **Green**: Write the *dumbest, fastest* code to make the test pass. Don't architect yet. Just make it green.
*   **Refactor**: Now that you have a safety net, clean up the code. Extract methods, apply design patterns (like Strategy or Factory), and remove duplication. *The test must stay green.*

## 2. The Test Pyramid

Not all tests are created equal. Inverted or "Ice-Cream Cone" pyramids (lots of UI tests, few unit tests) lead to slow, flaky builds.

*   **Unit Tests (70%)**: Fast, in-memory, isolated tests of pure business logic (Service layer, utility algorithms). Zero database hits, zero network calls. They should run in milliseconds.
*   **Integration Tests (20%)**: Test the boundaries. Database repositories (e.g., using `@DataJpaTest` and Testcontainers), Kafka producers/consumers, and external API clients (using WireMock).
*   **End-to-End (E2E) Tests (10%)**: The whole stack running (Backend + DB + Frontend). Very slow, very brittle, but necessary for critical user journeys (e.g., "The Complete Payment Flow").

## 3. Mocking vs. Stubbing (and when to use neither)

Over-mocking makes tests brittle. If you change a private implementation detail and 50 tests break, your tests are coupled to the *implementation*, not the *behavior*.

*   **Mocks**: Used to verify *interactions* (e.g., `verify(emailService).send(any())`). Use sparingly.
*   **Stubs**: Used to provide canned answers (e.g., `when(rateRepository.find()).thenReturn(dummyRates)`).
*   **Fakes/In-Memory Implementations**: Often superior to Mocks. Instead of mocking a UserRepository, provide an `InMemoryUserRepository` that uses a `HashMap`. It behaves exactly like the real thing and never breaks when implementation details change.
*   **The "No-Mock" Rule**: Never mock domain entities, Value Objects, or pure data structures. Just instantiate them. 

## 4. Arrange-Act-Assert (AAA)

Every test must follow a strict, scannable structure. Do not mix setup, execution, and verification.

```java
@Test
public void shouldCalculateCorrectFeeForHighRiskCounterparty() {
    // Arrange (Setup the world)
    Deal deal = testDataFactory.createHighRiskDeal(1_000_000);
    FeeCalculator calculator = new FeeCalculator(0.05);

    // Act (The single behavior being tested)
    BigDecimal fee = calculator.calculate(deal);

    // Assert (Verify the outcome)
    assertThat(fee).isEqualByComparingTo("50000.00");
}
```

## 5. Test against Behaviors, not Methods

Don't write a test called `testCalculateFee()`. Write tests that describe the business behavior.
*   **Bad**: `testProcessPayment()`
*   **Good**: `shouldRejectPaymentWhenDailyLimitIsExceeded()`
*   **Good**: `shouldCreateAlertWhenCounterpartyRiskIsHigh()`

*Why?* When a test fails in the CI pipeline, the method name alone should tell you exactly what business rule was broken.

## 6. Property-Based Testing

Instead of hardcoding specific inputs (e.g., `2 + 2 = 4`), define properties that must always hold true, and let the framework generate thousands of random inputs.

*   **Example**: For a sorting algorithm, instead of testing `[3,1,2] -> [1,2,3]`, assert that:
    1. The output size equals the input size.
    2. Every element in the output `i` is `<= i+1`.
*   *(Tooling: Jqwik for Java, Hypothesis for Python)*

## 7. Dependency Injection & Testability

If a class is hard to test, its design is flawed.
*   **Hidden Dependencies**: Doing `new RestTemplate()` inside a method makes it impossible to substitute for testing.
*   **Solution**: Inject dependencies via the constructor. This is the entire reason Spring/Guice exist.

## 8. Continuous Integration (The "Broken Window" Theory)

A test suite is worthless if it's ignored.

*   **Fail the Build**: If coverage drops below the threshold (e.g., 85%), or a single test fails, the Pull Request cannot be merged.
*   **Testcontainers**: Never rely on a shared staging database for Integration tests. Use Testcontainers (Docker) to spin up a fresh, isolated PostgreSQL or Redis instance for every test run.
*   **Mutation Testing**: (Advanced) Tools like *Pitest* actively modify your source code (e.g., changing `if (a > b)` to `if (a >= b)`) and run your tests. If the tests still pass, your tests are weak (they didn't catch the mutation).
