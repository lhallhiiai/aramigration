import { Badge } from "@/components/ui/badge";
import { getStatusLabel, getStatusVariant } from "@/lib/ara-helpers";
import type { AraStatus } from "@/types/enums";

interface AraStatusBadgeProps {
  status: AraStatus;
}

export function AraStatusBadge({ status }: AraStatusBadgeProps) {
  return (
    <Badge variant={getStatusVariant(status)}>
      {getStatusLabel(status)}
    </Badge>
  );
}
