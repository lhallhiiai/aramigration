import { AraStatusBadge } from "./AraStatusBadge";
import { getRiskCategoryLabel } from "@/lib/ara-helpers";
import { formatCurrency, formatDate } from "@/lib/format";
import { Separator } from "@/components/ui/separator";
import type { AraDetail } from "@/types";

interface AraDetailHeaderProps {
  ara: AraDetail;
}

export function AraDetailHeader({ ara }: AraDetailHeaderProps) {
  return (
    <div className="space-y-3">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <h2 className="text-2xl font-bold">
            {ara.reference ?? `ARA #${ara.araId}`}
          </h2>
          <AraStatusBadge status={ara.status} />
          {ara.revision > 0 && (
            <span className="text-sm text-muted-foreground">
              Rev. {ara.revision}
            </span>
          )}
        </div>
        <div className="text-right">
          <p className="text-2xl font-bold">
            {formatCurrency(ara.amountTotal)}
          </p>
          <p className="text-xs text-muted-foreground">Total Amount</p>
        </div>
      </div>
      <Separator />
      <div className="flex flex-wrap gap-x-8 gap-y-1 text-sm text-muted-foreground">
        <span>
          Category:{" "}
          <strong className="text-foreground">
            {getRiskCategoryLabel(ara.riskCategory)}
          </strong>
        </span>
        {ara.contractNumber && (
          <span>
            Contract: <strong className="text-foreground">{ara.contractNumber}</strong>
          </span>
        )}
        {ara.omsNumber && (
          <span>
            OMS: <strong className="text-foreground">{ara.omsNumber}</strong>
          </span>
        )}
        {ara.title && (
          <span>
            Title: <strong className="text-foreground">{ara.title}</strong>
          </span>
        )}
        {ara.startDate && (
          <span>Start: {formatDate(ara.startDate)}</span>
        )}
        {ara.expirationDate && (
          <span>Expires: {formatDate(ara.expirationDate)}</span>
        )}
        <span>Created: {formatDate(ara.createdAt)}</span>
      </div>
    </div>
  );
}
