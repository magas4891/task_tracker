/**
 * Shim for Trix when loaded from CDN (window.Trix).
 * Used so @rails/actiontext gets Trix without bundling the full package.
 */
export default typeof window !== "undefined" ? window.Trix : undefined;
