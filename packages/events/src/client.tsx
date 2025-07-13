import {
  OpenPanelComponent,
  type PostEventPayload,
  useOpenPanel,
} from "@openpanel/nextjs";

const isProd = process.env.NODE_ENV === "production";

const Provider = () => {
  // Disable OpenPanel if client ID is not properly configured
  const clientId = process.env.NEXT_PUBLIC_OPENPANEL_CLIENT_ID;
  
  if (!clientId || clientId === 'undefined' || !clientId.match(/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i)) {
    console.warn('OpenPanel client ID not configured properly, skipping analytics');
    return null;
  }

  return (
    <OpenPanelComponent
      clientId={clientId}
      trackAttributes={true}
      trackScreenViews={isProd}
      trackOutgoingLinks={isProd}
    />
  );
};

const track = (options: { event: string } & PostEventPayload["properties"]) => {
  if (!isProd) {
    console.log("Track", options);
    return;
  }

  try {
    const { track: openTrack } = useOpenPanel();
    const { event, ...rest } = options;
    openTrack?.(event, rest);
  } catch (error) {
    console.warn('OpenPanel tracking failed:', error);
  }
};

export { Provider, track };
