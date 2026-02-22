import { format, parseISO } from "date-fns";
import { CURRENCY_LOCALE, CURRENCY_OPTIONS } from "./constants";

const currencyFormatter = new Intl.NumberFormat(CURRENCY_LOCALE, CURRENCY_OPTIONS);

export function formatCurrency(amount: number): string {
  return currencyFormatter.format(amount);
}

export function formatDate(isoString: string | null | undefined): string {
  if (!isoString) return "";
  return format(parseISO(isoString), "MM/dd/yyyy");
}

export function formatDateTime(isoString: string | null | undefined): string {
  if (!isoString) return "";
  return format(parseISO(isoString), "MM/dd/yyyy h:mm a");
}
