/* Copyright (c) 2012, individual contributors
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#import "GNAutocompleteDictionary.h"

@implementation GNAutocompleteDictionary

-(id)init
{
    self = [super init];
    if(self)
    {
        backingStore = [[NSMutableSet alloc] init];
        numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier: @"en_US"]]; // TODO: add more locales?
    }
    return self;
}

-(void)addTextToBackingStore:(NSArray*)lines
{
    // Empty the previous backing store
    [backingStore setSet:[NSSet set]];
    
    NSMutableCharacterSet* stoppingCharacters = [NSMutableCharacterSet whitespaceCharacterSet];
    [stoppingCharacters formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
    [stoppingCharacters formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
    
    for(NSString* text in lines)
    {
        NSArray* splitText = [text componentsSeparatedByCharactersInSet:stoppingCharacters];
        for(NSString* textElement in splitText)
        {
            if([numberFormatter numberFromString:textElement] == nil)
            {
                // Ok, this *should* be sane stuff, that's not a number
                [backingStore addObject:textElement];
            }
        }
    }
}

-(NSArray*)orderedMatchesForText:(NSString*)text
{
    // Filter our internal backing store based on starting with text
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(SELF != %@) AND (SELF beginswith %@)",text,text];
    
    NSMutableArray* elementsMatchingText = [NSMutableArray arrayWithArray:[[backingStore filteredSetUsingPredicate:predicate] allObjects]];
    
    // Sort elementsMatchingText by length, in ascending order
    NSSortDescriptor* ascendingSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"length" ascending:YES];
    NSArray* sortDescriptors = [NSArray arrayWithObject:ascendingSortDescriptor];
    [elementsMatchingText sortUsingDescriptors:sortDescriptors];
    
    return [NSArray arrayWithArray:elementsMatchingText];
}

@end
