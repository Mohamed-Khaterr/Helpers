
struct Validator {
    func email(_ email: String) -> Bool  {
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: email, options: [], range: NSRange(location: 0, length: email.count)) != nil
    }
    
    /// Validate the phone number according to Egyptian numbers
    ///
    /// - ✅ 2010... | +2010... |  010... | 011... |  012... |  015...
    /// - ❌ 00022101381 | 2013... | +2014... | 01122101381 | 01622101381
    func phone(_ phone: String) -> Bool {
        // Remove all Special characters and Alphabetic characters
        let numbersOnly = phone.components(separatedBy: .decimalDigits.inverted).joined()
        
        // Phone number checker Regex check URL
        // https://regexlib.com/REDetails.aspx?regexp_id=27721
        let phoneRegEx = "^(\\+(?=2))?2?01(?![3-4])[0-5]{1}[0-9]{8}$"
        
        let phoneTest = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
        let result = phoneTest.evaluate(with: numbersOnly)
        return result
    }
    
    
    func username(_ username: String) -> Bool {
        /*
         ^(?=.{8,20}$)(?![_.])(?!.*[_.]{2})[a-zA-Z0-9._]+(?<![_.])$
          └─────┬────┘└───┬──┘└─────┬─────┘└─────┬─────┘ └───┬───┘
                │         │         │            │           no _ or . at the end
                │         │         │            │
                │         │         │            allowed characters
                │         │         │
                │         │         no __ or _. or ._ or .. inside
                │         │
                │         no _ or . at the beginning
                │
                username is 8-20 characters long
         */
        let usernameRagEx = "^(?=[a-zA-Z0-9._]{8,20}$)(?!.*[_.]{2})[^_.].*[^_.]$"
        let predicate = NSPredicate(format:"SELF MATCHES %@", usernameRagEx)
        return predicate.evaluate(with: username)
    }
}
