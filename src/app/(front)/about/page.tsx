import Link from "next/link";
import AppLoading from "../components/app-loading";
import { Suspense } from "react";

async function ApiVersion() {
  const response = await fetch('https://api.thanatornPik.com/api/version');
  const apiInfo = await response.json();

  return (
    <div className="rounded-xl border p-6 text-center">
      <p className="text-muted-foreground">
        API Version: <span className="font-medium text-foreground">{apiInfo.data.version}</span>
      </p>
    </div>
  );
}

// http://localhost:3000/about
export default function AboutPage() {
  return (
    <div className="flex min-h-screen items-center justify-center px-6 py-20">
      <div className="w-full grow sm:max-w-(--breakpoint-md) lg:max-w-(--breakpoint-lg)">
        <h1 className="mx-auto text-center font-medium text-4xl tracking-[-0.045em] sm:text-[2.75rem]/[1.2]">
          About Us
        </h1>
        <p className="mt-3 text-pretty text-center text-lg text-muted-foreground tracking-[-0.01em] sm:text-2xl">
          รู้จักเราเพิ่มเติม
        </p>

        <div className="mx-auto mt-12 max-w-2xl space-y-6">
          <Suspense fallback={<AppLoading />}>
            <ApiVersion />
          </Suspense>
        </div>

        <div className="mt-12 text-center">
          <Link href="/" className="underline text-muted-foreground hover:text-foreground">
            กลับหน้าหลัก
          </Link>
        </div>
      </div>
    </div>
  );
}