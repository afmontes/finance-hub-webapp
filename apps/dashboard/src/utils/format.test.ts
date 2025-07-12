import { describe, expect, it } from "bun:test";
import { formatAmount } from "./format";

describe("formatAmount", () => {
  it("should format positive amounts correctly", () => {
    const result = formatAmount({
      amount: 1000,
      currency: "USD",
    });
    expect(result).toBe("$1,000.00");
  });

  it("should format negative amounts correctly", () => {
    const result = formatAmount({
      amount: -1000,
      currency: "USD",
    });
    expect(result).toBe("-$1,000.00");
  });

  it("should format different currencies correctly", () => {
    const result = formatAmount({
      amount: 1000,
      currency: "CAD",
    });
    expect(result).toBe("CA$1,000.00");
  });

  it("should handle zero amounts", () => {
    const result = formatAmount({
      amount: 0,
      currency: "USD",
    });
    expect(result).toBe("$0.00");
  });

  it("should format large amounts correctly", () => {
    const result = formatAmount({
      amount: 1000000, // $1,000,000.00
      currency: "USD",
    });
    expect(result).toBe("$1,000,000.00");
  });

  it("should return undefined for missing currency", () => {
    const result = formatAmount({
      amount: 1000,
      currency: undefined as any,
    });
    expect(result).toBeUndefined();
  });

  it("should handle decimal amounts", () => {
    const result = formatAmount({
      amount: 123.45,
      currency: "USD",
    });
    expect(result).toBe("$123.45");
  });
});
