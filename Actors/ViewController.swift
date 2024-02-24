//
//  ViewController.swift
//  Actors
//
//  Created by Vinod Supnekar on 23/02/24.
//

import UIKit

class ViewController: UIViewController {

    private var name = ""
    
    @IBOutlet var imageView: UIImageView!

    func updateName() {
        DispatchQueue.global().async {
            self.name.append("asas")
        }
        print("\(self.name)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        updateName()
        
        let flight = FlightAsActor()
        
        let queue1 = DispatchQueue(label: "queue1")
        let queue2 = DispatchQueue(label: "queue2")
        
        queue1.async {
            
            Task {
                let bookedSeat = await flight.bookSeat()
                print(" booked seat is \(bookedSeat)")
            }
        }
        
        queue2.async {
            Task {
                let availableSeat = await flight.getAvailbaleSeats()
                print(" availableSeat seats are \(availableSeat)")
            }
        }
        
        /* Async Await :-  (swift book)
         https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/

         Use Case:-

         - Get List Of Photo Gallery and download the first image from result

         This can be done with series if asynchronous calls serially:-

         listPhotos(inGallery: "Summer Vacation") { photoNames in
             let sortedNames = photoNames.sorted()
             let name = sortedNames[0]
             downloadPhoto(named: name) { photo in
                 show(photo)
             }
         }

         *******

         Even in this simple case, because the code has to be written as a series of completion handlers, we end up writing nested closures.
          In this style, more complex code with deep nesting can quickly become unwieldy.


         An asynchronous function:-

             - An asynchronous function or asynchronous method is a special kind of function or method that can be     suspended while it’s partway through execution.

         - This is in contrast to ordinary, synchronous functions and methods, which either run to completion, throw an error, or never return.

         Ex.
         func listPhotos(inGallery name: String) async -> [String] {
             let result = // ... some asynchronous networking code ...
             return result
         }

         If it also throws then:-

         func listPhotos(inGallery name: String) async throws -> [String]


         For example, the code below fetches the names of all the pictures in a gallery and then shows the first picture:

         let photoNames = await listPhotos(inGallery: "Summer Vacation")
         let sortedNames = photoNames.sorted()
         let name = sortedNames[0]
         let photo = await downloadPhoto(named: name)
         show(photo)

         To understand the concurrent nature of the example above, here’s one possible order of execution:

         1. The code starts running from the first line and runs up to the first await. It calls the listPhotos(inGallery:) function and suspends execution while it waits for that function to return.
         2. While this code’s execution is suspended, some other concurrent code in the same program runs. For example, maybe a long-running background task continues updating a list of new photo galleries. That code also runs until the next suspension point, marked by await, or until it completes.
         3. After listPhotos(inGallery:) returns, this code continues execution starting at that point. It assigns the value that was returned to photoNames.
         4. The lines that define sortedNames and name are regular, synchronous code. Because nothing is marked await on these lines, there aren’t any possible suspension points.
         5. The next await marks the call to the downloadPhoto(named:) function. This code pauses execution again until that function returns, giving other concurrent code an opportunity to run.
         6. After downloadPhoto(named:) returns, its return value is assigned to photo and then passed as an argument when calling show(_:).

        Task :-
        
        /*
         The task creates a concurrency supporting environment in which we can call the async method executeTask(). Interestingly, our code executes even though we didn’t keep a reference to the created task within the on appear method
         
         */
         */
        
        Task { 
            do {
                let image = try await fetchImage()
                imageView.image = image
            } catch {
                print("Image loading failed: \(error)")
            }
        }
    }
    
    
    func fetchImage() async throws -> UIImage? {
            let imageTask = Task { () -> UIImage? in
                let imageURL = URL(string: "https://source.unsplash.com/random")!
                print("Starting network request...")
                let (imageData, _) = try await URLSession.shared.data(from: imageURL)
                return UIImage(data: imageData)
            }
        
            imageTask.cancel()
        
        /*The cancellation call above is enough to stop the request from succeeding since the URLSession implementation performs cancellation checks before execution. Therefore, the above code example is printing out the following:
         
         */
            return try await imageTask.value
        }


}


// Using Actors:-

actor FlightAsActor{
    
    let company = "Vistara"

    
    var availabelSeats = ["1A", "2B", "3C"]
    
    func getAvailbaleSeats() -> [String] {
        return availabelSeats
    }
    
    func bookSeat() -> String {
            
        let bookedSeat = availabelSeats.first ?? ""
        availabelSeats.removeFirst()
        return bookedSeat
    }
}

