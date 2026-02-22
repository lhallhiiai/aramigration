import { Card, CardContent } from "@/components/ui/card";
import { Label } from "@/components/ui/label";
import { useCategories } from "@/hooks/useCategories";
import { LoadingState } from "@/components/shared/LoadingState";
import { ErrorState } from "@/components/shared/ErrorState";
import { RiskCategory } from "@/types/enums";
import { cn } from "@/lib/utils";

interface Step1RiskCategoryProps {
  selectedCategoryId: number;
  onSelect: (categoryId: number, isEarlyStart: boolean) => void;
}

export function Step1RiskCategory({
  selectedCategoryId,
  onSelect,
}: Step1RiskCategoryProps) {
  const { data: categories, isLoading, isError, refetch } = useCategories();

  if (isLoading) return <LoadingState rows={4} />;
  if (isError) return <ErrorState onRetry={() => refetch()} />;

  return (
    <div className="space-y-4">
      <div>
        <Label className="text-base font-semibold">
          Select Risk Category
        </Label>
        <p className="mt-1 text-sm text-muted-foreground">
          Choose the risk category that best describes this ARA.
        </p>
      </div>
      <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
        {categories?.map((cat) => {
          const isSelected = cat.categoryId === selectedCategoryId;
          const isPreContract =
            cat.categoryId === RiskCategory.PreContractCosts;

          return (
            <Card
              key={cat.categoryId}
              className={cn(
                "cursor-pointer transition-colors hover:border-primary",
                isSelected && "border-primary bg-primary/5",
              )}
              onClick={() => onSelect(cat.categoryId, isPreContract)}
            >
              <CardContent className="p-4">
                <p className="text-sm font-medium">{cat.categoryName}</p>
                {isPreContract && (
                  <p className="mt-1 text-xs text-muted-foreground">
                    Early Start
                  </p>
                )}
              </CardContent>
            </Card>
          );
        })}
      </div>
    </div>
  );
}
