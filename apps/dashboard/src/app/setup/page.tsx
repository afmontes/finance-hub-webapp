import { Button } from "@midday/ui/button";
import { Input } from "@midday/ui/input";
import { Label } from "@midday/ui/label";

export default function SetupPage() {
  return (
    <div className="min-h-screen flex items-center justify-center p-4">
      <div className="w-full max-w-md space-y-6">
        <div className="text-center">
          <h1 className="text-2xl font-bold">Setup Your Team</h1>
          <p className="text-gray-600 mt-2">
            Create your first team to get started with your finance hub.
          </p>
        </div>

        <form className="space-y-4" id="setup-form">
          <div>
            <Label htmlFor="name">Team Name</Label>
            <Input
              id="name"
              name="name"
              placeholder="My Finance Team"
              required
            />
          </div>

          <div>
            <Label htmlFor="baseCurrency">Currency</Label>
            <select
              id="baseCurrency"
              name="baseCurrency"
              className="w-full p-2 border rounded-md"
              required
            >
              <option value="USD">USD - US Dollar</option>
              <option value="CAD">CAD - Canadian Dollar</option>
              <option value="EUR">EUR - Euro</option>
              <option value="GBP">GBP - British Pound</option>
            </select>
          </div>

          <div>
            <Label htmlFor="countryCode">Country</Label>
            <select
              id="countryCode"
              name="countryCode"
              className="w-full p-2 border rounded-md"
              required
            >
              <option value="US">United States</option>
              <option value="CA">Canada</option>
              <option value="GB">United Kingdom</option>
              <option value="DE">Germany</option>
            </select>
          </div>

          <Button type="submit" className="w-full">
            Create Team
          </Button>
        </form>

        <script
          dangerouslySetInnerHTML={{
            __html: `
            document.getElementById('setup-form').addEventListener('submit', async (e) => {
              e.preventDefault();
              const formData = new FormData(e.target);
              const data = Object.fromEntries(formData);
              
              try {
                const response = await fetch('/api/setup/create-initial-team', {
                  method: 'POST',
                  headers: { 'Content-Type': 'application/json' },
                  body: JSON.stringify(data)
                });
                
                const result = await response.json();
                
                if (result.success) {
                  alert('Team created successfully!');
                  window.location.href = '/';
                } else {
                  alert('Error: ' + result.error);
                }
              } catch (error) {
                alert('Failed to create team: ' + error.message);
              }
            });
          `,
          }}
        />
      </div>
    </div>
  );
}