"use client"
import ModalHero from "@/components/ModalHero"

export default function ModalLeftTopHandling() {
  return (
    <ModalHero
      title="Welcome to Our App"
      content={
        <div className="space-y-4">
          <p>This is a customizable hero panel that slides in from the left side of the screen.</p>
          <p>You can add any content here, such as:</p>
          <ul className="list-disc space-y-2 pl-5">
            <li>Important announcements</li>
            <li>Navigation options</li>
            <li>Featured content</li>
            <li>User information</li>
          </ul>
          <p>The panel takes up 3/4 of the screen height and 1/3 of the screen width.</p>
        </div>
      }
      buttonText="Open Hero Panel"
    />
  )
}
