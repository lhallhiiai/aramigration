import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { AraTable } from "@/components/Ara/AraTable";
import { usePendingAras, useActiveAras } from "@/hooks/useAras";

export function ActionListPage() {
  const pending = usePendingAras();
  const active = useActiveAras();

  return (
    <div className="space-y-4">
      <h2 className="text-2xl font-bold">Action List</h2>
      <Tabs defaultValue="my-actions">
        <TabsList>
          <TabsTrigger value="my-actions">My Action List</TabsTrigger>
          <TabsTrigger value="all-aras">See All ARAs</TabsTrigger>
        </TabsList>
        <TabsContent value="my-actions" className="mt-4">
          <AraTable
            aras={pending.data}
            isLoading={pending.isLoading}
            isError={pending.isError}
            emptyMessage="No ARAs are currently awaiting your action."
            onRetry={() => pending.refetch()}
          />
        </TabsContent>
        <TabsContent value="all-aras" className="mt-4">
          <AraTable
            aras={active.data}
            isLoading={active.isLoading}
            isError={active.isError}
            emptyMessage="No active ARAs in the system."
            onRetry={() => active.refetch()}
          />
        </TabsContent>
      </Tabs>
    </div>
  );
}
